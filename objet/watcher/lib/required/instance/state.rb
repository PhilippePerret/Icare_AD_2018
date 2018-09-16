# encoding: UTF-8
class SiteHtml
class Watcher

  # RETURN true si la tâche est en dépassement de plus de 7 jours
  def overrun?
    triggered && Time.now.to_i > triggered + 7.days
  end

end #/Watcher
end #/SiteHtml
