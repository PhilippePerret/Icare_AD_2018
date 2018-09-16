# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end
class Unan
class Program
class PageCours

  include MethodesLinksProgramThings

  # Retourne les identifiants des travaux de la page courante
  def works_ids
    @works_ids ||= begin
      where_clause = "type_w IN (#{Unan::Program::AbsWork::CODES_BY_TYPE[:pages].join(',')}) AND item_id = #{id}"
      search_works_where(where_clause).collect { |h| h[:id] }
    end
  end

  # Affiche les works qui utilisent cette page de cours
  # C'est-à-dire les works de type_w page de cours qui ont pour
  # item_id cette page de cours
  def getof_work
    error_does_not_exist
    raise "La page de cours ##{id} n'est utilisée par aucun travail (abs-work)" if works_ids.empty?
    mess = "La page de cours ##{id} est utilisée par "
    mess << (works_ids.count > 1 ? "les travaux #{works_ids.pretty_join}" : "le travail ##{works_ids.first}")
    mess << "."
    sub_log mess
    sub_log all_liens_works(works_ids)
  rescue Exception => e
    sub_log e.message
    false
  else
    true
  ensure
    sub_log(all_liens_pages_cours(id).in_div(class:'grand air'))
  end

  # Les PDay absolus qui utilisent cette page de cours, donc pour savoir
  # quel(s) jour(s) cette page doit être lue.
  def getof_pday
    error_does_not_exist
    raise "La page de cours ##{id} n'est utilisée par aucun travail (abs-work), donc forcément à aucune jour-programme." if works_ids.empty?
    # Il faut trouver les jours-programmes des works
    pdays_ids = search_pdays_of_works( works_ids )
    sub_log all_liens_pdays(self, pdays_ids)
  rescue Exception => e
    sub_log "# #{e.message}".in_p
    false
  else
    true
  ensure
    sub_log(all_liens_pages_cours(id).in_div(class:'grand air'))
  end

  # Retourne les Quiz associés à cette page de cours.
  # Cela revient à chercher les balises [quiz::...] dans les textes
  # de la page.
  def getof_quiz
    error_does_not_exist
    sub_log "Rechercher les quiz associés à des pages de cours consiste à rechercher les balises <code>[quiz:...]</code> dans les textes et description de la page.".in_div(class:'small')
    # Pour tester
    # @description  = "Ceci est une description pour exemple qui contient un lien vers un [quiz::1] et un autre [quiz::2::le titre de l'exemple]."
    @content      = "Ceci est un texte de fichier pour exemple qui contient un lien vers un [quiz::3] et un autre [quiz::4::le titre de l'exemple]."
    quiz_ids = Array::new
    # La description de la page (dans la base/table)
    description.scan(/\[quiz::([0-9]+)(?:::|\])/).each do |found|
      quiz_ids << found.first.to_i
    end
    # Le contenu textuel de la page
    content.scan(/\[quiz::([0-9]+)(?:::|\])/).each do |found|
      quiz_ids << found.first.to_i
    end
    raise "La page de cours ##{id} (#{titre}) n'est en relation avec aucun quiz." if quiz_ids.empty?
    unseul = quiz_ids.count == 1
    mess = "La page ##{id} est en relation avec "
    mess << (unseul ? "le quiz ##{quiz_ids.first}" : "les quiz #{quiz_ids.pretty_join}")
    mess << "."
    sub_log mess.in_p
    sub_log( all_liens_quiz( quiz_ids ) )
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log(all_liens_pages_cours(id).in_div(class:'grand air'))
  end

  # Retourne tous les exemples associés à cette page de cours
  # Cela revient à demander les exemples qui sont contenus dans
  # le texte de cette page de cours. Il faut lire son fichier.
  # Note : on fait une recherche complète sur les différents textes,
  # même sur
  def getof_exemple
    error_does_not_exist

    sub_log "Rechercher les exemples associés à des pages de cours consiste à rechercher les balises <code>[exemples:...]</code> dans les textes et description de la page.".in_div(class:'small')

    # Pour tester :
    # @description  = "Ceci est une description pour exemple qui contient un lien vers un [exemple::1] et un autre [exemple::2::le titre de l'exemple]."
    # @content      = "Ceci est un texte de fichier pour exemple qui contient un lien vers un [exemple::3] et un autre [exemple::4::le titre de l'exemple]."

    exemples_ids = Array::new

    # La description de la page (dans la base/table)
    description.scan(/\[exemple::([0-9]+)(?:::|\])/).each do |found|
      exemples_ids << found.first.to_i
    end

    # Le contenu textuel de la page
    content.scan(/\[exemple::([0-9]+)(?:::|\])/).each do |found|
      exemples_ids << found.first.to_i
    end

    raise "La page de cours ##{id} (#{titre}) n'est en relation avec aucun exemple." if exemples_ids.empty?

    unseul = exemples_ids.count == 1
    mess = "La page ##{id} est en relation avec "
    mess << (unseul ? "l'exemple ##{exemples_ids.first}" : "les exemples #{exemples_ids.pretty_join}")
    mess << "."
    sub_log mess.in_p
    sub_log( all_liens_exemples( exemples_ids ) )

  rescue Exception => e
    sub_log "# #{e.message}".in_p
    false
  else
    true
  ensure
    sub_log(all_liens_pages_cours(id).in_div(class:'grand air'))
  end

  # Retourne la page de cours associée à ce jour-programme, s'il
  # est associé à une page de cours
  def getof_page_cours
    error_does_not_exist
    raise "Une page de cours ne peut pas être associée à une page de cours, voyons."
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log(all_liens_pages_cours(id).in_div(class:'grand air'))
  end


end #/AbsPDay
end #/Program
end #/Unan
