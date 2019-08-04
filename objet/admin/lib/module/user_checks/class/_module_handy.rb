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
      # On l'efface dans la liste des watchers
      icarien.all_watchers.delete(watchers.first[:id])
    when 0 then
      # Il faut ajouter un nouveau watcher
      add_check '', "Aucun watcher n'a été trouvé", false
      sol_id  = "+watcher-#{newdata[:objet]}-#{newdata[:objet_id]}-#{newdata[:processus]}"
      sol_msg = "Créer le watcher '#{newdata[:processus]}'"
      newdata.merge!(created_at:now, updated_at:now)
      correct(sol_id, sol_msg, db, tb, nil, newdata)
    else
      # Il faut prendre le dernier et détruire les autres
      lastw = watchers.pop
      add_check '', "Plusieurs watchers ont été trouvés…", false
      # On l'efface dans la liste des watchers
      icarien.all_watchers.delete(lastw[:id])
    end
  end

end #/Module
