# encoding: UTF-8
class SuperFile

  def initialize given_path
    @path = case given_path
    when String     then given_path
    when Array      then File.join( given_path )
    when SuperFile  then given_path.path
    else
      raise ArgumentError, "SuperFile doit être instancié avec un string (path) ou un array (['path', 'to', 'the', 'file'])"
    end
  end

  # Ré-initialise toutes les propriétés
  # NE PAS OUBLIER DE REDÉFINIR @path JUSTE APRÈS
  def reset reset_all = true
    # @path         = nil
    @dirname          = nil
    @name             = nil
    @expanded_path    = nil
    @code_html        = nil
    @affixe           = nil
    @extension        = nil
    @path_affixe      = nil
    @is_file          = nil
    @is_markdown      = nil
    @html_path        = nil
    @zip_path         = nil
    @extension_valid  = nil
    reset_all && begin
      @errors           = nil
    end
  end

end

# Require all instance modules
folder_instance = File.join(SuperFile::root, 'lib', 'superfile', 'instance')
raise "Impossible de trouver #{folder_instance}" unless File.exist? folder_instance
Dir["#{folder_instance}/**/*.rb"].each { |m| require m }
