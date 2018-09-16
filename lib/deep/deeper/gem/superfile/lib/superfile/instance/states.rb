# encoding: UTF-8
class SuperFile
  
  # ---------------------------------------------------------------------
  #   Méthodes d'état
  # ---------------------------------------------------------------------
  def exist?
    File.exist? path
  end
  alias :exists? :exist?
  
  def directory?
    return nil unless exist?
    @is_directory ||= File.directory? path
  end
  alias :folder? :directory?
  
  # ---------------------------------------------------------------------
  #   Méthodes pour fichiers
  # ---------------------------------------------------------------------
  
  # {T/F} Return TRUE if file is a real file
  # Return NIL if file doesn't exist
  def file?
    return nil unless exist?
    @is_file ||= false == File.directory?(path)
  end

  # {TrueClass|FlasClass} Return TRUE if file is a markdown file
  def markdown?
    @is_markdown ||= ["md", "markdown"].include?( extension.to_s.downcase )
  end
  
  # Retourne TRUE si le sujet est plus vieux que l'argument
  # +compfile+ {SuperFile || String}
  # +strict+    Si true, le fichier doit être réellement plus vieux
  #             Sinon, la méthode renvoie true quand les deux fichiers sont de
  #             même date
  def older_than? compfile, strict = false
    compfile = SuperFile::new(compfile) if compfile.class == String
    if exist? && compfile.exist?
      if strict
        mtime < compfile.mtime
      else
        mtime <= compfile.mtime
      end
    else
      add_error( ERRORS[:inexistant] % {path: path} ) unless exist?
      add_error( ERRORS[:inexistant] % {path: compfile.path} ) unless compfile.exist?
      return nil
    end
  end
  
  # Retourne true si le fichier Mardown possède un fichier HTML
  # up-to-date
  # Ne fonctionne qu'avec les fichiers Mardown
  # Rappel : les fichier HTML sont placés dans le dossier :
  #   restsite/html/markdown/
  # avec la même hiérarchie de dossier que le fichier dans restsite
  def uptodate?
    unless exist? && markdown?
      raise error( ERRORS[:inexistant] % {path: path} ) unless exist?
      raise "La méthode #uptodate? ne s'applique qu'aux fichiers Markdown."
    end
    return false if false == html_path.exist?
    self.older_than? html_path
  end
  
end