# encoding: UTF-8
=begin
Pour requérir "de force" des gems

SYNTAXE

  require_gem '<name>', '<version>'

Le gem doit exister en tant que gem ou dans le dossier ../.gems/gems du serveur

Si `version` n'est pas fourni, l'instance recherche un dossier
qui peut commencer par le `name` fourni.

=end
# def require_gem name, version
#   FakeGem::new(name, version).require_gem
# end
class FakeGem

  class << self

    def gems_folder
      @gems_folder ||= begin
        if ONLINE
          File.expand_path(File.join('..','.gems','gems'))
        else
          File.expand_path(File.join('AlwaysData','.gems','gems'))
        end
      end
    end
    def local_gems_folder
      # NOTE ! NE PAS UTILISER SuperFile ici ni aucune méthode qui
      # l'utilise, car le gem n'est pas encore chargé
      @local_gems_folder ||= File.join('.','lib','Gems')
    end

  end #/<< self

  attr_reader :name
  attr_reader :version
  # Le nom du dossier contenant le gem, composé à l'aide
  # du :name et de :version (":name-:version")
  attr_reader :folder_name
  # Le nom réel du dossier contenant le gem, trouvé par recherche
  attr_reader :real_folder_name
  # Le path réel du dossier contenant le gem
  attr_reader :real_folder_path
  # Le nom réel du gem (normalement, doit être égal à :name)
  attr_reader :gem_name

  def initialize name, version
    @name     = name
    @version  = version
  end

  def relative_main
    @relative_main ||= "./#{real_main_file_name}"
  end

  def require_gem
    # Ancienne version obsolète
    if is_real_gem?
      require_real_gem
    else
      require_faux_gem
    end
  end

  def require_real_gem
    $: << folder_lib
    require main_file_path
  end

  # Un de mes faux gems, comme any ou superfile
  def require_faux_gem
    rel_main  = "./#{real_main_file_name}"
    Dir.chdir( folder_lib ){
      require "./#{real_main_file_name}"
    }
  end

  def is_real_gem?
    folder_path if @is_real_gem === nil
    @is_real_gem
  end

  # Si le fichier "naturel" n'existe pas, on cherche le premier
  # fichier ruby. Cela se produit par exemple avec le gem
  # rubyzip dont le main a pour nom zip.rb
  def real_main_file_name
    @real_main_file_name ||= File.basename( main_file_path )
  end
  # Path du vrai fichier ruby principal existant.
  # Si le fichier "naturel" n'existe pas (celui portant le même
  # nom que le gem) on prend le premier fichier ruby existant
  # au même niveau que la librairie
  def main_file_path
    @main_file ||= begin
      mainrb = File.join( folder_lib, "#{name}.rb" )
      unless File.exist? mainrb
        mainrb = Dir["#{folder_lib}/*.rb"].first
      end
      mainrb
    end
  end

  def folder_lib
    @folder_lib ||= File.join( folder_path, 'lib' )
  end

  def folder_path
    @folder_path ||= begin
      pathg = File.join( self.class::gems_folder, folder_name)
      @is_real_gem = File.exist? pathg
      unless is_real_gem?
        # => Ce n'est pas un vrai gem
        pathg = File.join(self.class::local_gems_folder,folder_name)
        raise "Impossible de trouver le dossier gem #{pathg}…" unless File.exist? pathg
      end
      pathg
    end
  end

  def folder_name
    @folder_name ||= begin
      if version.nil?
        name.to_s
      else
        version.start_with?( name ) ? version.to_s : "#{name}-#{version}"
      end
    end
  end

end
