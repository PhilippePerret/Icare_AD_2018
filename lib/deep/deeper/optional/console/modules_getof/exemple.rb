# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end
class Unan
class Program
class Exemple

  include MethodesLinksProgramThings

  # {Array} Retourne la liste des identifiants des abs-work
  # qui utilisent l'exemple courant
  # Note : Utiliser @resultat_works_of_exemple pour récupérer
  # d'autres informations sur les works ramassés.
  def ids_works_of_exemple colonnes = []
    colonnes = [colonnes] unless colonnes.instance_of?(Array)
    colonnes << :exemples
    res = search_works_where("exemples LIKE '%#{id}%'", colonnes)

    # Pour mettre les résultats des works récoltés, s'il y a d'autres choses
    # que les ids à utilisés. En clé, l'identifiant du work et en valeur
    # le hash de ses données, suivant les colonnes demandées à commencer par
    # la colonne :exemples.
    @resultat_works_of_exemple = Hash.new

    # Ci-dessus on peut avoir récupérer aussi bien "121 12 212" pour "12", mais
    # il ne faudrait garder que "12" par exemple. On filtre ci-dessous
    id_str = id.to_s.freeze
    res.select do |hdata|
      hdata[:exemples].split(' ').include?(id_str)
    end.collect do |h|
      # Pour mettre en réserve les autres données
      @resultat_works_of_exemple.merge!(h[:id] => h)
      # Pour retourner l'identifiant
      h[:id]
    end
  end

  def getof_work
    error_does_not_exist
    ids = ids_works_of_exemple
    raise "L'exemple ##{id} n'est associé à aucun travail." if ids.empty?
    mess = "L'exemple ##{id} est associé "
    mess << (ids.count > 1 ? "aux travaux (abs_work) #{ids.pretty_join}" : "au travail ##{ids.first}")
    mess << "."
    sub_log mess
    sub_log( all_liens_works(ids) )
  rescue Exception => e
    sub_log e.message
    false
  else
    true
  ensure
    sub_log (all_liens_exemples(id)).in_div(class:'grand air')
  end

  # Affiche les liens d'édition pour les P-Days associés à cet
  # exemple
  def getof_pday
    error_does_not_exist

    ids_works = ids_works_of_exemple
    raise "L'exemple ##{id} n'est associé à aucun travail (work) donc forcément aucun jour-programme." if ids_works.count == 0

    ids = search_pdays_of_works( ids_works )
    if ids.empty?
      mess_error = "L'exemple ##{id} est associé "
      mess_error << (ids.count > 1 ? "aux works #{ids_works.pretty_join}" : "au work ##{ids_works.first}")
      mess_error << " mais "
      mess_error << (ids.count > 1 ? "aucun de ces travaux" : "ce travail")
      mess_error << " n'est associé à aucun jour-programme. Cet exemple n'est donc pas associé à un jour-programme."
      raise mess_error
    end
    sub_log all_liens_pdays( self, ids ) # Module MethodesLinksProgramThings

  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log (all_liens_exemples(id) + all_liens_works(ids_works)).in_div(class:'grand air')
  end

  # Retourne le Quiz associé à cet exemple. Ça n'a pas vraiment de
  # sens donc on ne fait rien
  def getof_quiz
    error_does_not_exist
    sub_log "Un exemple ne peut pas être associé à un quiz."
    false
  end

  # Retourne tous les exemples, ce qui est absurde en l'occurence
  def getof_exemple
    error_does_not_exist
    sub_log "Voyons… Un exemple ne peut pas avoir d'exemples…"
    false
  end

  # Retourne les pages de cours qui peuvent être associées à
  # cet exemple. Comme pour les p-days, cela revient à passer
  # par les works, mais ici par les works de type page de cours
  # seulement.
  def getof_page_cours
    error_does_not_exist

    ids_works = ids_works_of_exemple([:type_w, :item_id])
    raise "L'exemple ##{id} n'est associé à aucun travail (work) donc forcément aucune page de cours ne peut lui être associé." if ids_works.count == 0

    ids_page_cours = ids_works.collect do |wid|
      wdata = @resultat_works_of_exemple[wid] # défini dans ids_works_of_exemple
      if Unan::Program::AbsWork::CODES_BY_TYPE[:pages].include?( wdata[:type_w].to_i )
        wdata[:item_id].to_i
      else
        nil
      end
    end.compact
    raise "L'exemple ##{id} n'est associé à aucun travail de type page de cours." if ids_page_cours.count == 0

    sub_log( all_liens_pages_cours(ids_page_cours) )
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log (all_liens_exemples(id) + all_liens_works(ids_works)).in_div(class:'grand air')
  end


end #/Exemple
end #/Program
end #/Unan
