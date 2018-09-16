# encoding: UTF-8
=begin

Méthodes de préparation de la construction du livre

=end
class LaTexBook
class << self

  def prepare_book
    log "* Préparation du livre"
    if all_sources_tex_file.exist?
      log "  * Destruction du fichier all_sources.tex"
      all_sources_tex_file.remove
    end
    log "  * Nettoyage du dossier des sources latex"
    sources_folder.remove if sources_folder.exist?
    sources_folder.build
    log "  * Nettoyage du dossier des assets propres au livre"
    assets_folder.remove if assets_folder.exist?
    assets_folder.build
    log "  * Nettoyage du dossier des images"
    images_folder.remove if images_folder.exist?
    images_folder.build
    log "  * Nettoyage des fichiers auxiliaires"
    nettoie_fichiers_auxiliaires
    if main_pdf_file.exist?
      log "  * Destruction du fichier main.pdf existant"
      main_pdf_file.remove
    end
    log "= Préparation du livre OK"
  end

  # Nettoyage (donc suppression) des fichiers auxiliaires pour
  # être certain de repartir à zéro et de tout refaire
  def nettoie_fichiers_auxiliaires
    Dir["#{compilation_folder}/**/*.aux"].each do |paux|
      File.unlink paux
    end
  end

  def log mess; current.log( mess ) end

end #/<< self
end #/LaTexBook
