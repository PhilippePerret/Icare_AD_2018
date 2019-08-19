# encoding: UTF-8
class Ranking
  class GooglePage
    class GoogleFound

      # Données du found
      #
      # Utilise pour ne pas enregistrer d'objets comme les nœuds qui
      # n'existeront plus une fois la page fermée
      def data
        {
          titre:        titre_found,
          href:         href,
          domain:       domain_url,
          page_index:   page_index,
          link_index:   real_index,
          keyword:      keyword
        }
      end

      # Le mot-clé qui a généré
      def keyword
        @keyword ||= google_page.rank.keyword
      end

    end #/GoogleFound
  end #/GooglePage
end #/Ranking
