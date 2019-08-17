# encoding: UTF-8
class SiteHtml
class Admin
class Console
  def envoyer_tweet message
    site.require_module 'twitter'
    res = site.tweet message
    return "Tweet envoyé avec succès"
  end
end #/Console
end #/Admin
end #/SiteHtml
