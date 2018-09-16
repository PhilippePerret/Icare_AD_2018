# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end
class Unan
class Program
class AbsWork

  include MethodesLinksProgramThings

  # Retourne le PDay absolu du travail courant
  # Note : Un seul pour un AbsWork
  def getof_pday
    error_does_not_exist
    ids = search_pdays_of_works( id )
    raise "Le work ##{id} n'est associé à aucun jour-programme." if ids.count == 0
    sub_log all_liens_pdays( self, ids ) # Module MethodesLinksProgramThings

  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  end

  # Retourne le Quiz associé à cet AbsWork, s'il existe
  # Pour qu'il existe, il faut que ce work soit de type questionnaire,
  # on prend alors son item_id
  def getof_quiz
    error_does_not_exist
    error_no_type_w
    if data_type_w[:id_list] == :quiz
      sub_log "Questionnaire ##{item_id.inspect} pour le work ##{id} de titre “#{titre}”."
      sub_log all_liens_quiz(item_id)
    else
      sub_log "Pas de quiz associé à ce work, il n'est pas de type-w questionnaire."
      false
    end
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  end

  # Retourne tous les exemples de cet AbsWork, s'il y en a
  def getof_exemple
    error_does_not_exist
    error_no_type_w
    if exemples.empty?
      sub_log "Le work ##{id} “#{titre}” ne possède aucun exemple."
      false
    else
      sub_log(all_liens_exemples(exemples.split(' ').collect{|id| id.to_i}))
    end
    sub_log "Pour éditer ce work##{id} : #{all_liens_works(id)}".in_div(class:'air')
  end

  # Retourne la page de cours associée à cet AbsWork, s'il
  # est associé à une page de cours
  def getof_page_cours
    error_does_not_exist
    error_no_type_w
    if data_type_w[:id_list] == :pages
      sub_log "Page de cours ##{item_id.inspect} pour le work ##{id} : #{titre}."
      sub_log all_liens_pages_cours(item_id)
    else
      sub_log "Pas de page de cours."
      false
    end
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  end


end #/AbsWork
end #/Program
end #/Unan
