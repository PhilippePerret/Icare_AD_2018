=begin
  Méthodes pour les messages
=end
module HandyCheckerMethods

  def fdate time
    Time.at(time).strftime('%d/%m/%Y - %H:%M')
  end

  def now
    Time.now.to_i
  end

  # Reçoit une table et retourne une condition SQL
  # {prop: value, prop2:value2} => "prop = value AND prop2 = value2"
  def h2sql_condition h
    h.collect do |e,v|
      "#{e} = #{v.is_a?(String) ? "\"#{v}\"" : v}"
    end.join(' AND ')
  end

  # Reçoit une liste de 0 ou plus données de watchers (Hash) et ne doit en
  # conserver qu'un seul
  # @return {Boolean}
  #         True si la donnée est conforme, false si elle doit être corrigée
  def traite_only_one_watchers watchers, db = nil, tb = nil, newdata
    case watchers.count
    when 1 then  # OK
      add_check '', "Le watcher a été trouvé, unique", true
    when 0 then
      # Il faut ajouter un nouveau watcher
      add_check '', "Aucun watcher n'a été trouvé", false
      add_solution("+watcher-#{newdata[:objet]}-#{newdata[:objet_id]}-#{newdata[:processus]}", "Créer le watcher '#{newdata[:processus]}'")
      newdata.merge!(created_at:now, updated_at:now)
      correct(db, tb, nil, newdata)
    else
      # Il faut prendre le dernier et détruire les autres
      lastw = whatchers.pop
      add_check '', "Plusieurs watchers ont été trouvés…", false
      add_solution("keep-only-one-watcher-#{newdata[:processus]}", "Il ne faut conserver que le watcher ##{lastw[:id]}.")
      watchers.each { |dataw| correct(db, tb, dataw[:id], 'DELETE') }
    end
  end

end #/Module
