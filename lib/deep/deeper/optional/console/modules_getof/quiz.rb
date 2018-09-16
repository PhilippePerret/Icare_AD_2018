# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end
class Unan
class Quiz

  include MethodesLinksProgramThings


  # {Array} Retourne la liste des identifiants des abs-work
  # qui utilisent le quiz courant
  # Note : Utiliser @resultat_works_of_exemple pour récupérer
  # d'autres informations sur les works ramassés.
  def ids_works_of_this colonnes = []
    colonnes = [colonnes] unless colonnes.instance_of?(Array)
    typesw = Unan::Program::AbsWork::CODES_BY_TYPE[:quiz].join(',')
    res = search_works_where("type_w IN (#{typesw}) AND item_id = #{id}", colonnes)

    # Pour mettre les résultats des works récoltés, s'il y a d'autres choses
    # que les ids à utilisés. En clé, l'identifiant du work et en valeur
    # le hash de ses données, suivant les colonnes demandées à commencer par
    # la colonne :exemples.
    @resultat_works_of_exemple = Hash.new

    res.collect do |hdata|
      @resultat_works_of_exemple.merge!(hdata[:id] => hdata)
      hdata[:id]
    end
  end


  # Affiche les works du quiz courant
  def getof_work
    error_does_not_exist
    works_ids = ids_works_of_this
    raise "Ce quiz ##{id} n'est associé à aucun travail (abs-work)" if works_ids.empty?
    mess = "Le quiz ##{id} est associé "
    mess << (works_ids.count > 1 ? "aux travaux #{works_ids.pretty_join}" : "au travail ##{works_ids.first}")
    mess << "."
    sub_log mess
    sub_log all_liens_works(works_ids)
  rescue Exception => e
    sub_log e.message
    false
  else
    true
  ensure
    sub_log( all_liens_quiz(id).in_div(class:'grand air') )
  end

  # Retourne les PDay absolu du quiz courant, si ce quiz est
  # utilisé plusieurs fois dans des travaux
  def getof_pday
    error_does_not_exist
    works_ids = ids_works_of_this
    raise "Ce quiz ##{id} n'est associé à aucun travail (abs-work)" if works_ids.empty?
    pdays_ids = Array::new
    works_ids.each do |wid|
      pdays_ids += search_pdays_of_works( wid )
    end
    raise "Le quiz ##{id} n'est associé à aucun jour-programme." if pdays_ids.count == 0

    sub_log all_liens_pdays( self, pdays_ids ) # Module MethodesLinksProgramThings

  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log( all_liens_quiz(id).in_div(class:'grand air') )
  end

  # Pas de quiz associé à un quiz
  def getof_quiz
    error_does_not_exist
    sub_log "Voyons, un quiz ne peut pas être associé à un quiz…"
    sub_log( all_liens_quiz(id).in_div(class:'grand air') )
    false
  end

  # Les exemples d'un quiz, ça n'a pas vraiment de sens, a
  # priori, mais ça en a un : en fait, il s'agit des quiz
  # qui peuvent être appelé depuis le texte même de l'exemple,
  # donc par la balise [quiz::<id>].
  def getof_exemple
    error_does_not_exist
    sub_log "Un quiz ne possède pas d'exemples, mais un exemple peut faire appel à un quiz dans son texte ([quiz::#{id}]). Ce sont ces exemples qui sont cherchés."
    ids = Unan::table_exemples.select(where:"content LIKE '%\[quiz::#{id}\]%' OR content LIKE '\[quiz::#{id}::%'", colonnes:[]).collect{|h|h[:id]}
    raise "Ce quiz ##{id} n'est invoqué par aucun exemple." if ids.empty?
    sub_log( all_liens_exemples(ids))
  rescue Exception => e
    sub_log e.message
    false
  ensure
    sub_log( all_liens_quiz(id).in_div(class:'grand air') )
  end

  # Retourne les page de cours associées à ce quiz, c'est-à-dire les
  # page de cours qui peuvent faire appel à lui par une balise [quiz].
  # Fonctionnement : on parcourt tous les textes des pages de cours
  # à la recherche de la balise. Si elle est trouvée, on prend le basename
  # du fichier pour retrouver l'identifiant de la page de cours
  def getof_page_cours
    error_does_not_exist
    sub_log "Un quiz ne possède pas de page de cours, mais une page de cours peut faire appel à un quiz dans son texte ([quiz::#{id}]). Ce sont ces pages de cours qui sont recherchées.".in_p
    regexp = /\[quiz::#{id}(:|\])/
    relpaths_pages = Array::new
    Dir["./data/unan/pages_cours/**/*.erb"].each do |path|
      content = File.open(path,'rb'){|f| f.read.force_encoding('utf-8')}
      if content.match(regexp)
        relpaths_pages << path.sub(/^\.\/data\/unan\/pages_cours\//,'')
      end
    end

    # Pour tester :
    # relpaths_pages = ['program/fondamentales/premiere_approche.erb', 'program/histoire/recherche_et_choix.erb']

    raise "Le quiz ##{id} n'est invoqué par aucune page de cours" if relpaths_pages.empty?
    pages_ids = relpaths_pages.collect do |relpath|
      relpath = relpath.split('/')
      page_type = relpath.shift
      page_path = relpath.join('/')
      id = Unan.table_pages_cours.select(where:"type = '#{page_type}' AND path = '#{page_path}'", colonnes:[]).first[:id]
      error "La page de cours de type `#{page_type}` et de relpath `#{page_path}` est inconnue de la table des pages de cours…" if id.nil?
      id
    end.compact # pour éviter les nil
    debug "pages_ids: #{pages_ids.inspect}"
    sub_log( all_liens_pages_cours(pages_ids))
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  ensure
    sub_log( all_liens_quiz(id).in_div(class:'grand air') )
  end

end #/Quiz
end #/Unan
