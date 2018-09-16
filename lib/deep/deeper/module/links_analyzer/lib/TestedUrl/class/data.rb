# encoding: UTF-8

# Pour permettre à Marshal de dumper les instances TestedPage,
# en attendant que Nokogiri implémente ces méthodes
class Nokogiri::HTML::Document; def _dump_data; nil end end
class Nokogiri::XML::Element; def _dump_data; nil end end
class Nokogiri::XML::Text; def _dump_data; nil end end

class TestedPage
  class << self
    # Temps de démarrage et de fin de l'opération d'analyse
    attr_reader :start_time, :end_time

    # {Hash} comportant en clé la route de la page testée
    # et en valeur l'instance TestedPage qui contient toutes
    # les données.
    attr_reader :instances

    # # {Hash} GROSSE TABLE CONTENANT TOUS LES RÉSULTATS
    # # OBSOLÈTE. Voir @instances, maintenant
    # attr_reader :hroutes

    # {Array} de toutes les routes à tester. On s'arrête lorsque
    # la liste est vide.
    # Les éléments sont les routes, donc les clés des instances, qu'on
    # peut récupérer par :
    #   TestedPage[<route>]
    attr_reader :routes

    # Liste des routes des pages (instances TestedPage) invalides
    # Note : dans leur @errors, on trouve la liste de leurs
    # erreurs.
    #
    # Pour les récupérer en tant qu'instance TestedPage, on
    # peut utiliser: TestedPage[<id>]
    #
    attr_reader :invalides

    # Nombre de routes exclues par EXCLUDED_ROUTES
    attr_accessor :routes_exclues_count

    # Compte total de liens. On pourrait les compter dans les instances,
    # mais c'est pour avoir un rapport plus rapide.
    attr_accessor :links_count

    # Dossier pour mettre les routes marshalisées
    def marshal_folder
      @marshal_folder ||= File.join(MAIN_FOLDER, 'output', 'routes_msh')
    end

    # Méthode qui sauve toutes les données récoltées, après
    # analyse de toutes les pages et merge des routes similaires.
    #
    # Cela permet de repartir de cette base-là dans le cas
    # où on travaille sur le rapport produit.
    def save_data_in_marshal
      File.unlink path_marshal if File.exist? path_marshal

      # On essaie de mettre toutes les instances de route dans un
      # dossier
      require 'fileutils'
      FileUtils::rm_rf(marshal_folder) if File.exist?(marshal_folder)
      Dir.mkdir(marshal_folder, 0777)

      # Comme certaines class n'implémentent pas la méthode _dump_data
      # qui perrmet de dumper les data, il faut les mettre à nil
      # Table qui va être enregistrée
      instances_marshal = Hash.new
      files_routes      = Array.new
      instances.each do |route, tpage|
        fname = "#{route.gsub(/[^a-zA-Z]/,'_')}.msh"
        fpath = File.join(marshal_folder, fname)
        File.open(fpath,'wb'){|f| Marshal.dump(tpage.data_marshal, f)}
        files_routes << fpath
      end
      data = {
        files_routes:  files_routes,
        invalides:      invalides,
        links_count:    links_count
      }
      File.open(path_marshal,'wb'){|f| Marshal.dump(data, f)}
    rescue Exception => e
      debug "# Impossible de dumper les données au format Marshal : #{e.message}"
      debug e.backtrace.join("\n")
      File.unlink path_marshal if File.exist? path_marshal
    end

    # Récupérer les dernières données du fichier Marshal
    #
    # Retourne TRUE si on a pu récupérer les données, FALSE dans le
    # cas contraire, ce qui entrainera l'analyse de force.
    def get_data_from_marshal
      if File.exist? path_marshal
        data = File.open(path_marshal,'rb'){|f| Marshal.load(f)}
        @instances    = Hash.new
        data[:files_routes].each do |fpath|
          datapage = File.open(fpath,'rb'){|f| Marshal.load(f)}
          tpage = new(datapage[:route])
          datapage.each{|k, v| tpage.instance_variable_set("@#{k}", v)}
          @instances.merge! tpage.route => tpage
        end
        @invalides    = data[:invalides]
        @links_count  = data[:links_count]
        say "= Data récupérées avec succès dans les fichiers Marshal ="
        return true
      else
        debug "Le fichier marshal (#{path_marshal}) n'existe pas. Impossible de récupérer les données."
        return false
      end
    rescue Exception => e
      debug "# Impossible de récupérer les data du fichier Marshal : #{e.message}"
      return false
    end

    # Retourne un Hash contenant les données minimales des instances pour
    # pouvoir les enregistrer
    def instances_as_data
      h = Hash.new
      instances.each do |route, tpage|
        h.merge!(route => tpage.data_marshal)
      end
      return h
    end

    def path_marshal
      @path_marshal ||= File.join(MAIN_FOLDER, 'output', 'marshal_data.msh')
    end

  end #/ << self
end #/TestedPage
