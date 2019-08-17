# encoding: UTF-8
class File
  class << self
    
    ##
    #
    # Retourne TRUE si le fichier +dest_path+ est plus récent que
    # le fichier +src_path+
    #
    def uptodate? src_path, dest_path
      raise ArgumentError, "Le fichier source `#{src_path}' est introuvable." unless exist? src_path
      raise ArgumentError, "Il faut fournir des path-string." unless src_path.class == String && dest_path.class == String
      return false unless exist? dest_path
      return File.stat(src_path).mtime < File.stat(dest_path).mtime
    end
    
  end # << self
  
end