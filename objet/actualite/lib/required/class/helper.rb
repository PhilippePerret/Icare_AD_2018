# encoding: UTF-8
class SiteHtml
class Actualite
class << self

  def listing_accueil
    self.require_module 'last_actualites'
    _build_file_last_actualites
  end
  
end #<< self
end #/Actualite
end #/SiteHtml
