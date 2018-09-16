# encoding: UTF-8
=begin
Extensions console pour obtenir une chose d'une autre par son
idenfiant, par exemple un AbsWork d'une page de cours, les PDays
d'un quiz utilisé plusieurs fois, les exemples ou pages de cours
d'un PDay particulier etc.
=end
class Unan
class Program
class AbsPDay

  include MethodesLinksProgramThings


  # Affiche les works du pday
  def getof_work
    error_does_not_exist
    works_ids = works(:as_ids)
    raise "Ce jour-programme ##{id} ne définit aucun travail (abs-work)" if works_ids.empty?
    mess = "Le jour-programme ##{id} définit "
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
    sub_log(all_liens_pdays(self, id).in_div(class:'grand air'))
  end

  # Le PDay absolu du pday courant n'a pas de sens
  # Note : Un seul pour un AbsWork
  def getof_pday
    error_does_not_exist
    raise "Un P-Day ne peut être associé à un P-Day, voyons…"
  rescue Exception => e
    sub_log "# #{e.message}".in_p
    false
  else
    true
  ensure
    sub_log(all_liens_pdays(self, id).in_div(class:'grand air'))
  end

  # Retourne les Quiz associés à ce P-Day.
  # Cela revient à :
  #   - chercher dans les abs-works du p-day
  #   - qui sont de type questionnaire
  #   - prendre les questionnaires par l'item_id
  def getof_quiz
    error_does_not_exist
    clause_where = "id IN (#{works(:as_ids).join(',')}) AND type_w IN (#{Unan::Program::AbsWork::CODES_BY_TYPE[:quiz].join(',')})"
    hworks = search_works_where(clause_where, [:item_id])
    raise "Le Jour-programme ##{id} n'a pour le moment aucun travail de type questionnaire." if hworks.empty?
    quiz_ids = hworks.collect do |hwork|
      hwork[:item_id]
    end
    sub_log( all_liens_quiz(quiz_ids ))
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log(all_liens_pdays(nil, id).in_div(class:'grand air'))
  end

  # Retourne tous les exemples de ce P-Day donc tous les exemples
  # qui sont utilisés dans ses works, s'il y en a
  def getof_exemple
    error_does_not_exist
    hworks = search_works_where("id IN (#{works(:as_ids).join(',')}) AND exemples IS NOT NULL AND exemples != 'NULL' AND exemples != ''", [:exemples])
    raise "Le Jour-programme ##{id} n'a pour le moment aucun travail contenant des exemples." if hworks.empty?
    exemples_ids = Array::new
    hworks.each do |hwork|
      exemples_ids += hwork[:exemples].split(' ')
    end
    sub_log( all_liens_exemples(exemples_ids ))
  rescue Exception => e
    sub_log "# #{e.message}".in_p
    false
  else
    true
  ensure
    sub_log(all_liens_pdays(nil, id).in_div(class:'grand air'))
  end

  # Retourne la page de cours associée à ce jour-programme, s'il
  # est associé à une page de cours
  def getof_page_cours
    error_does_not_exist
    hworks = search_works_where("id IN (#{works(:as_ids).join(',')}) AND type_w IN (#{Unan::Program::AbsWork::CODES_BY_TYPE[:pages].join(',')})", [:item_id])
    raise "Le Jour-programme ##{id} n'a pour le moment aucun travail concernant une page de cours." if hworks.empty?
    pages_ids = hworks.collect { |hwork| hwork[:item_id] }
    sub_log( all_liens_pages_cours(pages_ids ))
  rescue Exception => e
    sub_log "# #{e.message}"
    false
  else
    true
  ensure
    sub_log(all_liens_pdays(nil, id).in_div(class:'grand air'))
  end


end #/AbsPDay
end #/Program
end #/Unan
