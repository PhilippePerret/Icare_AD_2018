# encoding: UTF-8
class SuperFile

  # {String} Expanded path of file
  def expanded_path
    @expanded_path ||= File.expand_path(path.to_s)
  end
  alias :expanded :expanded_path

  # {String} Retourne la valeur du dossier relatif ('.')
  def relative_folder
    @relative_folder ||= File.expand_path('.')
  end

  # {SuperFile} Same path with other extension
  def path_with_ext ext
    ext = ".#{ext}" unless ext.start_with?('.')
    SuperFile::new File.join(dirname, "#{affixe}#{ext}")
  rescue Exception => e
    error e
    return nil
  end

  # {String} Affixe path (i.e. path without extension)
  def path_affixe
    @path_affixe ||= (folder + affixe).to_s
  end

  # {SuperFile} Le path du fichier HTML du fichier markdown
  def html_path
    @html_path ||= path_with_ext 'html'
  end

  # {SuperFile} Fichier zip du fichier/dossier
  def zip_path
    @zip_path ||= path_with_ext 'zip'
  end

end
