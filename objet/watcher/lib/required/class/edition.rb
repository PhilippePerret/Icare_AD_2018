# encoding: UTF-8
class SiteHtml
class Watcher
class << self

  # Création d'un nouveau watcher
  #
  # RETURN L'identifiant du nouveau watcher créé
  def create data_watcher
    data_watcher[:user_id] ||= user.id
    data_watcher.merge!(created_at: Time.now.to_i, updated_at: Time.now.to_i)
    return table.insert(data_watcher)
  end

end #/<< self
end #/Watcher
end #/SiteHtml
