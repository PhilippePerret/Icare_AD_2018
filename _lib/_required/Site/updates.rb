# encoding: UTF-8
class SiteHtml

  # Ajoute une actualisation dans la table `updates' (cold)
  #
  # Cet ajout peut se faire de façon automatique ou par la
  # console.
  #
  # @syntaxe    site.new_update( data )
  # Pour les données, cf. le manuel
  def new_update data
    require_module 'updates'
    SiteHtml::Updates.new_update data
  end


  # {SuperFile} Le fichier HTML consignant les toute dernières actualités
  # pour ne pas avoir à le reconstruire chaque fois.
  #
  # Ce fichier est détruit dès qu'on ajoute une actualité
  #
  def file_last_actualites
    @file_last_actualites ||= folder_objet+'actualite/listing_home.html'
  end

end #/SiteHtml
