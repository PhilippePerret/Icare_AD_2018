# encoding: UTF-8
raise_unless_identified
class QuaiDesDocs
class << self

  FILTRE_DATA = {
    user_id:    {hname: 'auteur'},
    module_id:  {hname: 'module'},
    etape_id:   {hname: 'étape'},
    annee:      {hname: 'année'},
    trimestre:  {hname: 'trimestre'}
  }

  def filtre
    @filtre ||= param(:qdd) || Hash.new
  end

  # = main =
  #
  # Méthode principale appelée lorsque l'on doit procéder à la
  # recherche.
  #
  def proceed_search
    filtre_ok? || return
    QuaiDesDocs.require_module 'listings'
    args = {
      filtre:           filtre_pour_as_ul,
      avertissement:    false,
      infos_document:   true,
      key_sorted:       'time_original ASC'
    }
    debug "args envoyés à as_ul: #{args.inspect}"
    @result = QuaiDesDocs.as_ul(args) || 'Aucun document n’a été trouvé avec ce filtre.'.in_p(class: 'big')
  end

  def resultat
    if @result.nil?
      ''
    else
      "Documents trouvés (#{QuaiDesDocs.nombre_documents_found})".in_h4 + @result
    end
  end

  # RETURN le filtre exprimé de façon humaine
  def filtre_humain

  end

  # RETURN le filtre adapté à la méthode `as_ul`
  def filtre_pour_as_ul
    f = Hash.new
    filtre_user?    && f.merge!(user_id:  filtre[:user_id].to_i)
    filtre_module?  && f.merge!(module:   filtre[:module_id].to_i)
    filtre_etape?   && f.merge!(etape:    filtre[:etape_id].to_i)
    if filtre_annee?
      from_time, to_time =
        if filtre_trimestre?
          an = filtre[:annee].to_i
          tr = filtre[:trimestre].to_i
          [start_of_trimestre(an, tr), end_of_trimestre(an, tr)]
        else
          [ Time.new(filtre[:annee].to_i, 1, 1),
            Time.new(filtre[:annee].to_i, 12, 31, 23, 59, 59)]
        end
      f.merge!(created_between: [from_time.to_i, to_time.to_i])
    elsif filtre_trimestre? # trimestre sans année
      # pour le moment ça n'est pas possible
    end
    return f
  end


  def filtre_user?; @filtre_user      ||= filtre[:cb_user_id] == 'on' end
  def filtre_module?; @filtre_module  ||= filtre[:cb_module_id]=='on' end
  def filtre_etape?
    @filtre_etape ||= begin
      filtre[:cb_etape_id]=='on' && filtre[:etape_id].nil_if_empty != nil
    end
  end
  def filtre_annee?; @filtre_annee    ||= filtre[:cb_annee]=='on' end
  def filtre_trimestre?; @filtre_trimestre ||= filtre[:cb_trimestre]=='on' end

  # True si la définition du filtre est correcte
  def filtre_ok?
    une_case_est_cochee = false
    FILTRE_DATA.each do |kfiltre, dfiltre|
      debug "kfiltre: #{kfiltre.inspect}"
      if filtre["cb_#{kfiltre}".to_sym] == 'on'
        next if kfiltre == :etape_id && filtre[:etape_id].nil_if_empty.nil?
        une_case_est_cochee = true
        break
      end
    end
    une_case_est_cochee || raise('Merci de sélectionner au moins un paramètre !')
    if filtre_trimestre? && !filtre_annee?
      error 'Filtrer le trimestre sans filtrer l’année n’est pas pris en compte.'
    end

  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

end #/<< self
end #/QuaiDesDocs


# debug "QuaiDesDocs.filtre : #{QuaiDesDocs.filtre.inspect}"
case param(:operation)
when 'search_qdd'
  QuaiDesDocs.proceed_search
end
