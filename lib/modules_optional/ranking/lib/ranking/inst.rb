# encoding: UTF-8
=begin

  Instance d'une recherche faite sur un texte (mot clé)

  @usage

      rank = Ranking.new(<string recherché dans les pages>)
      rank.analyze
      puts rank.result

=end
class Ranking

  # {String} Texte humain recherché
  attr_reader :keyword

  # {Hash} contenant tous les résultats
  attr_reader :resultats

  def initialize keyword
    @keyword = keyword
    @resultats = {
      keyword:        keyword,
      google_pages:   Array.new,
      google_founds:  Array.new
    }
  end

  def reset_resultats
    @resultats[:google_pages]   = Array.new
    @resultats[:google_founds]  = Array.new
  end

  def nombre_liens_max
    @nombre_liens_max ||= begin
      NOMBRE_FOUNDS_MAX || NOMBRE_PAGES_MAX * NOMBRE_LIENS_PER_PAGE
    end
  end

  def analyze
    data = {
      q:      keyword,
      start:  nil
    }
    index_page = 0
    (0..nombre_liens_max).step(10) do |i|
      index_page += 1
      data[:start] = i.to_s
      # Formation de la requête complète
      full_url = Ranking.search_url + '?' + data.collect{|k,v| "#{k}=#{CGI.escape v}"}.join('&')
      ofile = output_file(i)
      # Le -L : suivre la redirection
      console.sub_log "<pre>- #{ofile}\n#{full_url}</pre>"
      cmd = "curl -c #{Ranking.cookie_path} -b #{Ranking.cookie_path} -j -o \"#{ofile}\" -A \"#{Ranking.user_agent}\" -L #{full_url}"
      # === EXÉCUTION DE LA COMMANDE ===
      res = `#{cmd}`
      if File.exist? ofile
        gpage = Ranking::GooglePage.new(self, index_page, ofile, i, keyword)
        gpage.analyze
        # On enregistre les data de la gpage, pas la gpage elle-même
        @resultats[:google_pages] << gpage.data
      else
        raise "# Le fichier `#{ofile}` est introuvable…"
      end
    end
    # /fin de boucle sur les x pages/liens à consulter

  end
  # /analyse

  # = main =
  #
  # Retourne le résultat récolté
  # OBSOLÈTE : On laisse un peu de texte, mais maintenant, c'est surtout le
  # fichier marshal qui contient les résultats.
  def result
    titre = "Mots clés : #{keyword}"
    "#{titre}\n"      +
    "="*titre.length  + "\n"
  end


  def output_file i
    istr = i.to_s.rjust(4,'0')
    File.expand_path(File.join(Ranking.folder_google_pages, "#{keyword.as_normalized_filename}_page_#{istr}.htm"))
  end
end
