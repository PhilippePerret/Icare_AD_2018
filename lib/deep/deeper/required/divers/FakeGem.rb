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
      @local_gems_folder ||= File.join('.','lib','deep', 'deeper', 'gem')
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
  #
  # # ---------------------------------------------------------------------
  # #   Essai de nouvelle version
  # #   C'est la version qui fonctionne avec la class SiteHTML
  # # ---------------------------------------------------------------------
  #
  # # Pour requérir un gem dans le dossier ./lib/deep/deeper/gem
  # # La méthode s'appelle `require_deeper_gem` pour la classe SiteHtml
  # # +folder_name+ {String} Peut être le nom du dossier entier, donc
  # #               avec la version, ou seulement le nom du gem dans
  # #               lequel cas il faut chercher la dernière version.
  # #
  # def load_gem
  #   @folder_name = name
  #   @folder_name += "-#{version}" unless version.nil_if_empty.nil?
  #   seek_folder_gem_to_load
  #   if real_folder_name.nil?
  #     main_safed_log "# Impossible de trouver le gem #{@folder_name}"
  #     raise "Impossible de trouver le gem #{@folder_name}…"
  #   end
  #   @gem_name = gem_name_from_folder_name real_folder_name
  #   main_safed_log "GEM NAME : #{gem_name}"
  #   main_safed_log "GEM PATH FOLDER : #{real_folder_path}"
  #   $LOAD_PATH << "#{real_folder_path}/lib"
  #   # Le gem_name peut être sous la forme "multipart-post" ou
  #   # "multipart_post" (c'est-à-dire avec les tirets remplacés
  #   # par des "_"). Il faut donc tester avant
  #   @gem_name = if File.exist?(File.join(real_folder_path, @gem_name))
  #     @gem_name
  #   else
  #     @gem_name.gsub(/\-/,'_')
  #   end
  #   require @gem_name
  # end
  #
  # # Reçoit un nom de dossier tel que "multipart-post-2.0.1"
  # # et retourne le nom du gem : "multipart-post"
  # def gem_name_from_folder_name fname
  #   dname = fname.split('-')
  #   version = dname.pop if dname.length > 1
  #   gname   = dname.join('-')
  # end
  #
  # def main_safed_log mess
  #   ref_safe_log.puts mess
  # end
  # def ref_safe_log
  #   @ref_safe_log ||= File.open(safe_log_path, 'a')
  # end
  # def safe_log_path
  #   @safe_log_path ||= "./safe.log"
  # end
  # # Méthode qui va chercher le dossier du gem
  # # Retourne [gem_name, gem_version]
  # # Recherche avec ou sans version, dans le fichier gems général
  # # ou dans le fichier gem du RestSite
  # def seek_folder_gem_to_load
  #   @real_folder_name, @real_folder_path =
  #   if gems_restsite.include?(folder_name)
  #     main_safed_log "Dossier Gem #{folder_name} trouvé dans les gems RestSite"
  #     [folder_name, File.join(self.class::local_gems_folder, folder_name)]
  #   elsif commons_gems.include?(folder_name)
  #     main_safed_log "Dossier Gem #{folder_name} trouvé dans les gems généraux"
  #     [folder_name, File.join(self.class::gems_folder, folder_name)]
  #   else
  #     # Il faut chercher
  #     main_safed_log "Dossier Gem #{folder_name} non trouvé dans les gems RestSite ou généraux. Il faut le chercher par le nom."
  #     seek_folder_gem_with_gem_name
  #   end
  #   return nil
  # end
  # def seek_folder_gem_with_gem_name
  #   [
  #     [gems_restsite, self.class::local_gems_folder],
  #     [commons_gems,  self.class::gems_folder]
  #   ].each do |gems_folder_names, gems_folder_path|
  #     gems_folder_names.each do |real_folder_name|
  #       gname = (gem_name_from_folder_name real_folder_name)
  #       main_safed_log "Recherche avec #{real_folder_name} (gname = '#{gname}')"
  #       return [real_folder_name, File.join(gems_folder_path, real_folder_name)] if gname == folder_name
  #     end
  #   end
  # end
  # # Tous les GEMS du dossier gems généraux
  # def commons_gems
  #   @commons_gems ||= (folders_gems_in self.class::gems_folder)
  # end
  # # Tous les GEMS du dossier des gems RestSite (dans ./lib)
  # def gems_restsite
  #   @gems_restsite ||= (folders_gems_in self.class::local_gems_folder)
  # end
  # def folders_gems_in path
  #   Dir["#{path}/*"].collect do |p|
  #     next nil unless File.directory?(p)
  #     File.basename(p)
  #   end.compact
  # end
  #
  # # ---------------------------------------------------------------------
  # #   /Fin essai nouvelle version
  # # ---------------------------------------------------------------------

  def relative_main
    @relative_main ||= "./#{real_main_file_name}"
  end

  def require_gem
    #
    # # Nouvelle formule qui charge le gem même sans
    # # avoir la version
    # load_gem

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
