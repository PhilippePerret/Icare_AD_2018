# encoding: UTF-8
class Ranking

  def analyze_resultats
    @resultats.merge!(per_domain: Hash.new)

    resultats[:google_founds].each do |gfound|

      # Classement par domaine
      unless @resultats[:per_domain].key?(gfound.domain_url)
        @resultats[:per_domain].merge!(gfound.domain_url => {
          url:        gfound.domain_url,
          count:      0,
          founds:     Array.new,
          keywords:   Array.new
          })
      end
      @resultats[:per_domain][gfound.domain_url][:count]    += 1
      @resultats[:per_domain][gfound.domain_url][:founds]   << gfound
      @resultats[:per_domain][gfound.domain_url][:keywords] << gfound.keyword

    end
  end
  # /analyze_resultats

end #/Ranking
