# encoding: UTF-8
class SiteMap

  # ---------------------------------------------------------------------
  #   Class SiteMap::Location
  # ---------------------------------------------------------------------
  class Location
    attr_reader :data, :url, :lastmod, :changefreq, :priority
    # Pour une collection d'adresse (par ID)
    attr_reader :collection, :from, :to
    # Pour une vidéo (:url doit être défini)
    attr_reader :video_title, :video_description, :video_thumbnail, :video_loc
    # Par une méthode dans module/sitemap
    attr_reader :method
    # Nombre final d'url
    attr_reader :nombre_urls

    def initialize data
      @data = data
      data.each{|k,v| instance_variable_set("@#{k}", v)}
      @url ||= @collection
      @nombre_urls = 0
    end

    def as_xml
      if collection?
        collection_as_xml
      elsif method?
        method_as_xml
      else
        simple_as_xml
      end
    end

    # Un lien défini uniquement par une méthode, il faut
    # appeler la méthode
    def method_as_xml
      self.send(method.to_sym)
    end

    def collection_as_xml
      furl_temp = full_url
      (from..to).collect do |id|
        @full_url = furl_temp.gsub(/_ID_/, id.to_s)
        simple_as_xml
      end.join("\n")
    end

    def full_url
      @full_url ||= begin
        if url.start_with?('http')
          url
        else
          File.join(site.distant_url, url)
        end
      end
    end

    def collection?
      @is_collection ||= !collection.nil?
    end

    def video?
      @is_video ||= !video_loc.nil?
    end
    def method?
      @is_method ||= !method.nil?
    end

  end #/Location

end #/SiteMap
