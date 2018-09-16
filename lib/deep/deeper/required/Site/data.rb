# encoding: UTF-8
=begin
Class SiteHtml
--------------
Méthodes de données
=end
class SiteHtml

  # Pour surclasser le titre dans le fichier de configuration
  attr_writer :title
  # Pour définir le nom du site dans le logo, s'il est
  # différent de la balise :title
  attr_writer :logo_title

  # Le Title du site, servant notamment pour la bande logo
  # Il faut être surclassé par l'option de configuration de
  # même nom (`site.title` dans le fichier ./objet/site/config.rb)
  def title
    # @title ||= name.upcase # si singleton
    @title ||= self.class.name.upcase # si instance
  end
  def base
    @base ||= ( ONLINE ? distant_url : local_url ) + "/"
  end

  def logo_title
    @logo_title ||= title
  end

end
