# encoding: UTF-8
=begin

Méthodes de construction du livre

=end
class LaTexBook

  # = main =
  #
  # Méthode principale qui construit le livre dans le
  # dossier du livre.
  #
  # RETURN True en cas de succès et False en cas d'erreur
  #
  # +options+ {Hash} permettant de redéfinir toutes les
  # données du fichier `book_data.rb` (qui peut même ne
  # pas exister si toutes les données sont transmises)
  def build options = nil
    site.require_module('Kramdown')

    # La même instance LaTexBook peut servir à produire
    # plusieurs livre différents (qui partagent presque
    # les mêmes sources), à commencer par les versions
    # sexuées, il faut donc réinitialiser un certain
    # nombre de variable d'instance pour en tenir compte.
    reset_variables

    log "=== LaTexBook #{self.class::version} ==="
    log "* Date : #{Time.now}"

    # Chargement des données du livre (si le fichier
    # existe)
    file_book_data.require if file_book_data.exist?
    # Surclassement des données si un argument est
    # envoyé à la méthode
    if options != nil
      options.each{|k,v| instance_variable_set("@#{k}", v)}
    end

    log "* Construction du livre #{pdf_file}"

    # Vérification de la possibilité du travail
    check

    # Préparation du livre
    self.class::prepare_book

    # Copie des fichiers utiles (assets et compagnie)
    copie_usefull_files

    # Définition du fichier pour la version sexuée
    # s'il faut la faire
    define_file_version_sexued

    # On construit toutes les sources LaTex à partir
    # des sources Markdown
    Source::traite_all

    # On finit par la compilation du livre
    compile

    # Copie le main.pdf (dans le gem) vers sa destination finale
    copie_book_pdf_in_destination

    # Ici, le fichier PDF devrait exister. S'il n'existe pas
    # c'est qu'il y a eu un probleme
    raise pdf_does_not_exist unless pdf_file.exist?

    # Ouvrir le PDF si demandé
    open_book_pdf if open_it

  rescue Exception => e
    @last_error = e.message # sera affichée
    log "# Une erreur est malheureusement survenue : #{e.message}"
    log e.backtrace.join("\n")
    log "=== /LaTexBook ==="
    return false
  else
    log "= Construction du livre OK"
    log "=== /LaTexBook ==="
    return true
  end

  # Copie le fichier main.pdf créé vers sa destination
  # finale.
  def copie_book_pdf_in_destination
    log "* Copie de main.pdf vers le fichier de destination"
    FileUtils::cp LaTexBook::main_pdf_file.to_s, pdf_file.to_s
  end

  def open_book_pdf
    `open "#{pdf_file.to_s}"`
  end

  def define_file_version_sexued
    p = LaTexBook::assets_folder+"define_version_sexuee.tex"
    p.write <<-TEX
% === Définition de la verion homme/femme ===
\\newboolean{pourfille}
\\setboolean{pourfille}{#{version_femme ? 'true' : 'false'}}
    TEX
  end


  # Méthode qui vérifie que tout soit bien en place
  def check
    raise "Le dossier des sources doit être défini (livre.sources_folder)" if sources_folder.nil?
    self.pdf_name ||= "latex_book"
  end

  # Méthode qui copie dans le dossier du gem compilation les
  # fichiers utiles du livre, comme par exemple les assets
  def copie_usefull_files
    copie_assets
    copie_images
  end

  def copie_assets
    log "  * Copie des fichiers assets propres au livre"
    dassets = self.class::assets_folder
    ownfile = dassets+"propres.tex"; ownfile.remove if ownfile.exist?
    paux    = dassets+"propres.aux"; paux.remove if paux.exist?

    includes = Array::new
    Dir["#{assets_folder}/**/*.tex"].collect do |p|
      relpath = p.sub(/^#{Regexp::escape assets_folder.to_s}\//o,'')
      # On copie le fichier dans le dossier compilation/asset
      dest_path = dassets+relpath
      FileUtils::cp p, dest_path.to_s
      # Si c'est la couverture, c'est plus tard qu'elle doit être
      # inclusion, quand on sera déjà dans le begin{document}
      next if File.basename(p) == "cover.tex"
      # Sinon, pour un autre fichier, on l'inclut
      relpath = relpath[0..-5]
      includes << "\\input{assets/#{relpath}}"
    end
    ownfile.write includes.join("\n") unless includes.empty?
    log "  = #{includes.count} fichiers assets copiés"
  end

  def copie_images
    return unless images_folder.exist?
    images = Dir["#{images_folder}/**/*.*"] # pour le nombre
    return if images.count == 0
    log "  * Copie des images"
    # Note : si jamais j'ajoute une extension, penser qu'il y a
    # aussi des images au type PDF (.pdf)
    FileUtils::cp_r "#{images_folder.to_s}/", "#{LaTexBook::images_folder.folder}"
    log "  = #{images.count} fichiers images copiés"
  end

end #/LaTexBook
