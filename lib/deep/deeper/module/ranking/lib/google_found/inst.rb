# encoding: UTF-8
=begin

  Instance Ranking::GoogleFound
  -----------------------------
  Pour la gestion d'un trouvaille google

=end
require 'capybara'

class Ranking
  class GooglePage
    class GoogleFound

      # La page google ({Ranking::GooglePage}) contenant ce Found
      attr_reader :google_page

      # Le nœud envoyé à l'instanciation
      attr_reader :node

      # {Fixnum} Index du lien (depuis le tout premier)
      attr_reader :index

      # {Hash} Les données qui seront utilisées pour l'enregistrement
      # Voir la méthode
      # attr_reader :data

      # +gpage+   {Rankin::GooglePage} La page google
      # +node+    Nœud Nokogiri::XML::Element
      # +inode+   Index du lien dans la page
      #           Note : @google_page.index_first_found indique le premier
      #           index du lien (par exemple 10 pour la 2e page)
      def initialize gpage, node, inode
        @google_page  = gpage
        @node         = node
        @index        = inode
        @data         = Hash.new
      end

      def page_index
        @page_index ||= google_page.index
      end

      # = main =
      #
      # Analyze du noeud
      # Permet de récupérer le titre de la page (@titre_page), l'href
      # complète (@href) et le domaine (@domain_url)
      #
      def analyze
        get_href_and_url
      end

      # Retourne TRUE si le found est une "trouvaille" google valide,
      # avec un titre, un href et un nom de domaine.
      def valide?
        titre_found != nil && href != nil && domain_url != nil
      end

      # ---------------------------------------------------------------------
      #   Data du lien trouvé par google
      # ---------------------------------------------------------------------
      def titre_found
        @titre_found ||= begin
          # visible_text ?
          node.text
        end
      end

      # L'URL complète, valide ou non
      attr_reader :href
      # L'URL du domaine seulement (nil si n'existe pas)
      attr_reader :domain_url

      # Index réel de la page
      def real_index
        @read_index ||= google_page.index_first_found + index
      end

      # ---------------------------------------------------------------------
      #   Méthode d'analyse
      # ---------------------------------------------------------------------
      def get_href_and_url
        liens = node.find_css('a')
        liens.count > 0 || return

        @href = liens.first['href'].to_s
        offset_http = @href.index('http')
        offset_http != nil || return

        @href = @href[offset_http..-1]
        offset_slash = @href.index('//')
        offset_slash = @href.index('/', offset_slash + 2)
        @domain_url = @href[0..offset_slash-1]

      end
    end #/GoogleFound
  end #/GooglePage
end #/Ranking
