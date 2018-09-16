# encoding: UTF-8
=begin

=end
class User

  # Retourne les données Hash du watcher de l'icarien correspondant aux
  # données +wdata+
  def watcher wdata
    wdata.merge!(user_id: self.id)
    where = wdata.collect{|k,v| "#{k} = #{v.inspect}"}.join(' AND ')
    debug "Requête where : #{where.inspect}"
    dbtable_watchers.select(where: where).first
  end
  # TODO Peut-être faire une méthode `watchers` pour en
  # récupérer plusieurs.

  # Retourne true si l'utilisateur possède le
  # watcher défini par les données +wdata+ (qui doivent
  # donc être le plus précis possible)
  # La méthode renvoie false si l'utilisateur ne possède
  # aucun watcher valide ou le nombre de watcher dans le
  # cas contraire.
  def has_watcher? wdata
    wdata.merge!(user_id: self.id)
    where = wdata.collect{|k,v| "#{k} = #{v.inspect}"}.join(' AND ')
    debug "Requête where : #{where.inspect}"
    res = dbtable_watchers.select(where: where)
    res.count > 0 || (return false)
    res.count
  end

  # Ajoute un watcher pour l'icarien avec les données
  # fournies en argument
  # La méthode retourne le nouvel identifiant créé.
  def add_watcher wdata
    nowint = Time.now.to_i
    wdata.merge!(user_id: self.id, created_at: nowint, updated_at: nowint)
    wid = dbtable_watchers.insert(wdata)
  end

  # Détruit le watcher de l'user correspondant aux données
  # +wdata+
  #
  # Retourne le nombre de watcher détruit, 0 si aucun.
  def remove_watcher wdata
    wdata.merge!(user_id: self.id)
    whereclause = wdata.collect{|k, v|"#{k} = #{v.inspect}"}.join(' AND ')
    count_init = dbtable_watchers.count
    dbtable_watchers.delete(where: whereclause)
    return count_init - dbtable_watchers.count
  end

end
