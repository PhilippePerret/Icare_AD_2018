# encoding: UTF-8
class SuperFile

  attr_reader :errors

  # Construit le dossier
  # (et toute la hiérarchie nécessaire)
  # @return TRUE en cas de succès
  # Sinon, retourne FALSE et produit une erreur
  def build
    if exist?
      raise ERRORS[:already_exists] % {path: self.path}
    else
      begin
        make_dir self.path
        return self.exist?
      rescue Exception => e
        raise e.message
      end
    end
  end

  # Build path hierarchie up to file path
  # If +up_to_path+ is nil, build up to current file
  # So :
  #   sf = SuperFile::new '/path/to/my/folder
  #   sf = sf.make_dir
  #   # =>  build '/path', then '/path/to', 'then '/path/to/my'
  #   #     then '/path/to/my/folder' if needed
  #
  def make_dir up_to_path = nil
    up_to_path ||= path
    `if [ ! -d "#{up_to_path}" ];then mkdir -p "#{up_to_path}";fi`
  end


  # Détruit le fichier ou le dossier
  def remove
    raise "Unable to find file #{path}" unless exist?
    if file?
      File.unlink path
    else
      ::FileUtils::rm_rf path
    end
    return true
  end

  # Renomme le superfile
  # Attention : Il s'agit simplement d'un changement de
  # nom, +new_name+ est un nom de dossier, PAS un path
  def rename new_name
    new_path = (dirname + new_name).to_s
    ::FileUtils::mv path.to_s, new_path
  end

  # Renomme le SuperFile mais en le déplaçant
  # ailleurs
  # Note : Pour ne changer que le nom, utiliser plutôt
  # rename
  def move new_path
    ::FileUtils::mv path.to_s, new_path
  end

  alias :top_require :require
  ##
  # Require file (if a file) or all folder's files according to
  # +params+
  #
  # +params+ (only with folders)
  #   :deep       If true (default), require in folder and all sub-folders
  #   :only       Available values:
  #               :root     Require only root's files
  #               "a/sub/folder"    Require in this sub-folder
  #               Default: Nil
  def require params = nil
    raise "Unable de require file #{path}: it doesn't exist." unless exist?
    if file?
      top_require path
    else
      params ||= {}
      params.merge!( deep: true ) unless params.has_key? :deep
      req_path = "#{path}/"
      req_path += "#{params[:only]}/" if params[:only].class == String
      params[:deep] = false     if params[:only] == :root
      req_path << "**/"         if params[:deep]
      req_path << "*.rb"
      Dir[req_path].each { |m| top_require m }
    end
    return true
  end

  # Download le fichier/dossier
  # On en fait toujours un zip avant de le transmettre
  def download
    zip && zip_path.exist? || raise("Impossible de zipper le file #{path}…")
    STDOUT.puts "Content-type: application/zip"
    STDOUT.puts "Content-disposition: attachment;filename=\"#{zip_path.name}\""
    STDOUT.puts "Content-length: #{zip_path.size}"
    STDOUT.puts ""
    STDOUT.puts File.open( zip_path.expanded_path, 'rb'){ |f| f.read }
    zip_path.remove
  end


  class NotAUploadedFile < StandardError; end
  # Upload d'un fichier
  # +tempfile+  Le StringIO du fichier, comme obtenu par exemple par le
  #             formulaire de soumission.
  # +option+    {Hash} d'options
  #   :change_name      Si FALSE, ne modifie pas le nom de ce fichier
  #                     Si TRUE (défaut), le nom donné à l'instanciation de
  #                     ce superfile est remplacé par le nom du fichier à
  #                     uploader
  #   :normalize_filename   Si True, et que le nom doit être remplacé par le
  #                     nom original du fichier, on normalise ce nom original
  #                     avant de l'appliquer
  #   :nil_if_empty     Si TRUE (défaut), retourne NIL si le tempfile
  #                     est vide
  #   :affixe_max_length    Si défini, l'affixe du nom du fichier, quelle que
  #                     soit son extension, doit faire cette longueur. Le nom
  #                     sera raboté en conséquence s'il dépasse et une erreur
  #                     :affixe_reached_max_length sera produite (pour que la
  #                     méthode appelante puisse le savoir)
  #
  # RETURN
  #     True    En cas de succès
  #     False   En cas d'échec (avec affichage du message d'erreur)
  #     Nil     En cas de fichier inexistant ou vide (size = 0)
  #
  # ERREURS
  #     Elles sont mises dans @errors, un Array qu'on peut tester par :
  #     if superfile.errors.include?(:<id de l'erreur>)
  #
  def upload tempfile, options = nil
    @errors = Array.new
    options ||= Hash.new
    options.key?(:nil_if_empty) || options.merge!(nil_if_empty: true)
    options.key?(:change_name)  || options.merge!(change_name:  true)
    options.key?(:normalize_filename) || options.merge!(normalize_filename: !!options[:change_name])

    if (tempfile.nil? || tempfile == '' || tempfile.size == 0)
      if options[:nil_if_empty]
        return nil
      else
        raise(NotAUploadedFile)
      end
    end

    tempfile.respond_to?(:size)               || (raise NotAUploadedFile)
    tempfile.respond_to?(:original_filename)  || (raise NotAUploadedFile)

    # Nom du fichier
    # --------------
    # On l'attribue au superfile courant, sauf indication contraire
    tempfile_name = tempfile.original_filename
    if options[:change_name]
      options[:normalize_filename] && tempfile_name = tempfile_name.as_normalized_filename
      good_path = (dirname + tempfile_name).path
    else
      # Sinon, on garde la path original
      good_path = path
    end

    tempfile_extension = File.extname(tempfile_name)
    tempfile_affixe = File.basename(tempfile_name, tempfile_extension)
    if options[:affixe_max_length] && tempfile_affixe.length > options[:affixe_max_length]
      tempfile_name = tempfile_affixe[0..options[:affixe_max_length]-1] + tempfile_extension
      good_path = (dirname + tempfile_name).path
      add_error :affixe_reached_max_length
    end

    # Pour forcer le recalcul des propriétés après les changements précédents
    # éventuels
    reset(all = false) # all = false => pour garder les erreurs
    @name = tempfile_name
    @path = good_path

    # On écrit le fichier
    # --------------------
    self.write tempfile.read.force_encoding('UTF-8')

  rescue NotAUploadedFile => e
    debug e
    raise ArgumentError, "L'argument envoyé à SuperFile#upload doit être le fichier StringIO. Impossible d'uploader le fichier"
  rescue ArgumentError => e
    debug e
    raise ArgumentError, "#{e.message} Impossible d'uploader le fichier"
  rescue Exception => e
    debug e
    error e
  else
    return true
  end

  # Zip The File
  # ------------
  # +params+
  #     :filename     [Optionnel] Zip file name. If not provided,
  #                   name will be <affix>.zip
  def zip params = nil
    params ||= {}
    zip_final_path = if params.has_key?( :filename )
      params[:filename].expanded_path
    else
      zip_path.name
    end
    cmd = ""
    cmd << "cd \"#{dirname}\";"
    cmd << "zip "
    cmd << "-r " unless file?
    cmd << " \"#{zip_final_path}\" \"#{name}\""
    res = `#{cmd}`
    return zip_path.exist?
  end


  # Actualise le fichier si Markdown
  # @return TRUE si l'actualisation a pu se faire
  # sinon FALSE
  def update
    if false == exist?
      raise ERRORS[:inexistant] % {path: path}
    elsif false == markdown?
      raise "You can update only real markdown file"
    end
    # On peut opérer à l'actualisation
    top_require "kramdown"
    top_require "coderay"
    chtml = Kramdown::Document.new(read, auto_ids: false, coderay_line_numbers: nil, coderay_default_lang: 'fr', syntax_highlighter: :coderay, coderay_css: :style).to_html
    # Ne pas utiliser le nom `code_html' qui est une propriété de l'instance
    html_path.remove if html_path.exist?
    html_path.write chtml
    return true
  end

end
