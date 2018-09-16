# encoding: UTF-8
=begin

Module utilisé pour toutes les commandes `get of` qui
permettent d'obtenir les "choses" de "chose", par exemple :
`get works of pday 5`

=end
module MethodesLinksProgramThings

  def log mess      ; console.log mess      end
  def sub_log mess  ; console.sub_log mess  end


  def require_all_modules_of chose
    return if instance_variable_get("@module_of_#{chose}_required")
    Unan::require_module chose
    UnanAdmin::require_module chose
    instance_variable_set("@module_of_#{chose}_required", true)
  end

  # Retourne la liste {Array} des IDs de P-Days (AbsPDays) qui
  # contiennent/utilisent les travaux (AbsWork) d'identifiants
  # +arr_works_ids+
  def search_pdays_of_works arr_works_ids
    arr_works_ids = [arr_works_ids] unless arr_works_ids.instance_of?(Array)
    ids = Array::new
    arr_works_ids.each do |wid|
      res = search_pdays_where("works LIKE '%#{wid}%'", [:works])
      # Ci-dessus on peut avoir récupérer aussi bien "121 12 212" pour "12", mais
      # il ne faudrait garder que "12" par exemple. On filtre ci-dessous
      wid_str = wid.to_s.freeze
      ids += res.select do |hdata|
        hdata[:works].split(' ').include?(wid_str)
      end.collect{|h| h[:id]}
    end
    return ids
  end


  # Retourne tous les p-days qui répondent à la clause
  # where +where_clause+ en retourne la valeur des colonnes fournies
  # en arguments, ou seulement la valeur {id: id} si aucune colonne
  # n'est fournie.
  def search_pdays_where where_clause, colonnes = []
    Unan.table_absolute_pdays.select(where: where_clause, colonnes: colonnes)
  end
  # Retourne tous les abs-works qui répondent à la clause
  # where +where_clause+ et retourne la valeur des colonnes fournies
  # en arguments, ou seulement la valeur {id: id} si aucune colonne n'est
  # fournie
  def search_works_where where_clause, colonnes = []
    Unan::table_absolute_works.select(where: where_clause, colonnes: colonnes)
  end




  # Retourne tous les liens édition, aperçu et destruction pour
  # les PDays dont les IDs (ou l'ID) sont fourni en argument
  #
  def all_liens_pdays owner, arr_pdays_ids
    unless @module_absolute_pday_required
      UnanAdmin::require_module 'abs_pday'
      @module_absolute_pday_required = true
    end
    arr_pdays_ids = [arr_pdays_ids] unless arr_pdays_ids.instance_of?(Array)

    s = arr_pdays_ids.count > 1 ? "s" : ""
    unless owner.nil?
      sub_log "#{le_type_humain.capitalize} ##{owner.id} (#{owner.titre}) appartient au P-Day#{s} : #{arr_pdays_ids.pretty_join}"
    end
    arr_pdays_ids.collect do |pdid|
      ipday = Unan::Program::AbsPDay::get(pdid)
      e = pdid > 1 ? "e" : "er"
      (
        "#{pdid}<sup>#{e}</sup> Jour-Programme : " +
        ipday.lien_edit("[Edit]") +
        ipday.lien_show("[Show]") +
        ipday.lien_delete("[Delete]", {class:'warning'})
      ).in_div
    end.join("")
  end


  def liens_edition_for_allin_ofclass arr_ids, classe, options = nil
    arr_ids = [arr_ids] unless arr_ids.instance_of?(Array)
    arr_ids.collect do |inst_id|
      liens_edition_for( classe::get( inst_id ), options )
    end.join('')
  end

  def liens_edition_for inst, options = nil
    options ||= Hash.new
    (
      "#{inst.class} ##{inst.id} : " +
      inst.lien_edit("[Edit]") +
      inst.lien_show("[Show]", options[:options_show]) +
      inst.lien_delete("[Delete]", {class:'warning'})
    ).in_div
  end

  def all_liens_works arr_ids
    require_all_modules_of 'abs_work'
    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::AbsWork)
  end

  def all_liens_quiz arr_ids
    require_all_modules_of( 'quiz' )
    liens_edition_for_allin_ofclass(arr_ids, Unan::Quiz, {options_show:{user_id:2}})
  end

  def all_liens_exemples arr_ids
    require_all_modules_of('exemple')
    "Liens d'édition des exemples (#{arr_ids.inspect})" +
    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::Exemple)
  end

  # Retourne tous les liens (édition, aperçu et destruction) pour
  # les pages de cours dont les IDs sont fournis en argument
  #
  def all_liens_pages_cours arr_ids
    require_all_modules_of('page_cours')
    liens_edition_for_allin_ofclass(arr_ids, Unan::Program::PageCours)
  end

  def error_does_not_exist
    return if exist?
    raise "#{le_type_humain.capitalize} ##{id} n'existe pas, impossible d'obtenir ce que vous voulez."
  end
  def error_no_type_w
    return if type_w != nil
    raise "Le type_w #{du_type_humain}##{id} n'est pas défini… Impossible de le traiter."
  end

  def le_type_humain inst = nil
    # Note : On utilise .class.to_s car la classe n'est pas
    # forcément définie au moment où on appelle cette méthode
    case (inst || self).class.to_s
    when 'Unan::Program::AbsWork'   then "l'absolute-work"
    when 'Unan::Program::AbsPDay'   then "le jour-programme"
    when 'Unan::Program::PageCours' then "la page de cours"
    when 'Unan::Program::Exemple'   then "l'exemple"
    when 'Unan::Quiz' then "le quiz"
    else (inst || self).class.to_s
    end
  end
  def du_type_humain inst = nil
    case (inst || self).class.to_s
    when 'Unan::Program::AbsWork'   then "de l'absolute-work"
    when 'Unan::Program::AbsPDay'   then "du jour-programme"
    when 'Unan::Program::PageCours' then "de la page de cours"
    when 'Unan::Program::Exemple'   then "de l'exemple"
    when 'Unan::Quiz'               then "du quiz"
    else (inst || self).class.to_s
    end
  end
end
