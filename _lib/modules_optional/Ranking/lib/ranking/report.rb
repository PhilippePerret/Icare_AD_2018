# encoding: UTF-8
class Ranking

  # = main =
  #
  # Méthode principale qui va enregistrer les résultats obtenues pour
  # le test du mot-clé courant dans la base des résultats.
  #
  def finalise_resultats
    data_resultats = self.class.data_marshal
    data_resultats.merge!(keyword => self.data_marshal)
    # puts "data_resultats : #{data_resultats.pretty_inspect}"
    File.open(self.class.marshal_file,'wb'){|f| Marshal.dump(data_resultats, f)}
  end
  # Données marshal pour ce ranking (donc ce mot-clé)
  # La méthode n'est pas à confondre avec la méthode de classe de même nom
  # qui lit tous les résultats de tous les mots clés.
  def data_marshal
    {
      keyword:        keyword,
      resultats:      rational_resultats,
      raw_resultats:  resultats
    }
  end

  # Les résultats rationalisés, par exemple classés par nom de dommaines
  def rational_resultats
    resultats[:google_pages].each do |gpage_data|
      # Pour le contenu de `gpage_data', cf. le fichier
      # ./lib/deep/deeper/module/ranking/lib/google_page/data.rb

    end

    # Pour le classement par nom de domaine
    per_domain = Hash.new

    resultats[:google_founds].each do |gfound_data|
      # Pour le contenu de `gfound_data', cf. le fichier
      # ./lib/deep/deeper/module/ranking/lib/google_found/data.rb
      per_domain.key?(gfound_data[:domain]) || begin
        per_domain.merge! gfound_data[:domain] => {
          nombre_liens: 0,
          index_liens:  Array.new,
          keywords:     Array.new,
          founds_data:  Array.new
        }
      end

      h = per_domain[gfound_data[:domain]]
      h[:nombre_liens] += 1
      h[:index_liens]   << gfound_data[:link_index]
      h[:keywords]      << gfound_data[:keyword]
      h[:founds_data]   << gfound_data
    end

    # Données retournées, rationnalisées
    {
      per_domain: per_domain
    }
  end
  # /rational_resultats

  # = main =
  #
  # Construction du rapport
  #
  def report
    # On demande l'analyse des résultats
    analyze_resultats

    perdomain = resultats[:per_domain]
    perdomain = perdomain.sort_by{|ud, dd| dd[:count]}.reverse
    perdomain.each do |ud, dd|
      puts "- Domain: #{ud} / #{dd[:count]} fois"
    end
  end

end #/Ranking
