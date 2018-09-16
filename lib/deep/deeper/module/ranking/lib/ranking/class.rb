# encoding: UTF-8
class Ranking
  class << self

    def init
      # On crée le dossier pour les pages de résultats (que curl enregistre
      # dans un fichier — pour une consultation aisée)
      `rm -rf #{folder_google_pages}`
      `mkdir -p #{folder_google_pages}`
    end

    # Méthode appelée pour ré-initialiser tous les résultats, c'est-à-dire
    # détruire le fichier Marshal qui contient les données récoltées au
    # cours des recherches.
    def reset_data
      File.unlink marshal_file if File.exist? marshal_file
      if File.exist? marshal_file
        puts "# LE FICHIER MARSHAL N'A PAS PU ÊTRE SUPPRIMÉ"
      else
        puts "Le fichier marshal a été détruit."
      end
      @data_marshal = Hash.new
    end

    # Retourne la liste des keywords à traiter
    def keywords_undone
      @data_marshal = nil # pour forcer la (re)lecture du fichier
      dm = data_marshal.dup
      site.keywords != nil || raise('Pour lancer le ranking, il faut impérativement définir les mot-clés du site dans le fichier config (avec site.keywords)')
      site.keywords.instance_of?(Array) || raise('site.keywords devrait être une liste de mots-clés.')
      l = Array.new
      site.keywords.each do |kw|
        dm.key?(kw) && next
        l << kw
      end
      puts "Keywords : #{l.inspect}"
      return l
    end


    # Pour la méthode Curl, le site google en a besoin
    def user_agent
      @user_agent ||= 'Googlebot/2.1 (http://www.googlebot.com/bot.html)'
    end

    def search_url
      @search_url ||= 'http://www.google.fr/search'
    end

    def cookie_path
      @cookie_path ||= File.expand_path('./tmp/curl_cookie.txt')
    end

    def folder_google_pages
      @folder_google_pages ||= './tmp/google_pages'
    end

    # Toutes les données enregistrées dans le fichier marshal
    def data_marshal
      @data_marshal ||= begin
        if File.exist? marshal_file
          File.open(marshal_file,'rb'){|f| Marshal.load(f)}
        else
          Hash.new
        end
      end
      @data_marshal
    end
  def marshal_file
      @marshal_file ||= begin
        dos = File.expand_path('./tmp/ranking')
        `mkdir -p '#{dos}'`
        File.join('.', 'tmp', 'ranking', 'data.msh')
      end
    end

  end #/<< self
end #/Ranking
