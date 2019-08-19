# encoding: UTF-8
=begin

  Instance Ranking::GooglePage
  ----------------------------
  Une page google

=end
class Ranking
  class GooglePage

    include Capybara::DSL

    # {Ranking} Instance du ranking courant
    #
    # Répond notamment à la méthode `@resultats` pour mettre les
    # résultats.
    attr_reader :rank

    # Index de la page courante
    attr_reader :index

    # {String} Le path du fichier contenant le code du retour de la
    # commande cUrl (car on appelle la page et on l'enregistre)
    attr_reader :file_path

    # {Integer} Index du premier found dans ce fichier (de 10 en 10)
    attr_reader :index_first_found

    # {String} Le texte recherché, en version humaine
    attr_reader :searched


    # +path+ Path du fichier contenant le code HTML de la
    # page google
    def initialize rank, page_index, capybara_node #, path, index_start, searched
      @rank               = rank
      @capybara_node      = capybara_node
      @index              = page_index
      @index_first_found  = (page_index - 1) * Ranking::NOMBRE_LIENS_PER_PAGE
      @searched           = rank.keyword
    end

    def analyze
      all_founds.each_with_index do |node, inode|
        gf = GoogleFound.new(self, node, inode)
        gf.analyze
        gf.valide? || next
        if gf.domain_url == 'http://www.laboiteaoutilsdelauteur.fr'
          @domain_has_been_found = true
        end
        # Noter qu'on ne prend que les données du GoogleFound, car
        # l'instance poserait des problèmes avec les nodes qu'elle
        # contient et qui n'existent plus après fermeture des pages
        # Pour voir ce que contient data, cf.
        #   ./_lib/modules_optional/Ranking/lib/google_found/data.rb
        rank.resultats[:google_founds] << gf.data
      end
    end

    # Index d'un lien aléatoire qui sera cliqué pour informer
    # Google qu'un lien est cliqué (avant de revenir sur la page)
    def randon_clicked_link
      @randon_clicked_link ||= 1 + rand(7)
    end

    # On récupère l'URL courante pour l'appeler à nouveau après
    # avoir cliqué un lien.
    def current_window_location
      @current_window_location ||= begin
        page.execute_script('return window.location.href')
      end
    end

    def domain_found?
      !!@domain_has_been_found
    end

    def all_founds
      @all_founds ||= capybara_node.all('h3.r')
    end
    def capybara_node
      @capybara_node ||= Capybara::Node::Simple.new(file_content)
    end

    def file_content
      @file_content ||= File.open(file_path,'rb'){|f| f.read.force_encoding('utf-8')}
    end

  end #/GooglePage
end #/Ranking
