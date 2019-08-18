# encoding: UTF-8
class SiteMap
  class Location

    def simple_as_xml
      @nombre_urls += 1
      c = <<-XML
  <url>
    #{balise_loc}
    #{balise_priority}
    #{balise_last_modification}
    #{balise_frequence_changement}
    #{balise_video}
  </url>
      XML
      c = c.gsub(/\n([ \t]*)\n/, "\n")
      return c
    end

    def balise_loc
      "<loc>#{full_url}</loc>"
    end
    def balise_priority
      priority || (return '')
      "<priority>#{priority}</priority>"
    end

    def balise_last_modification
      lastmod || (return '')
      value_lastmod =
        case lastmod
        when /([0-9]{4,4})-([0-9]{2,2})-([0-9]{2,2})/
          lastmod
        when true
          File.stat("./_objet/#{url}.erb").mtime.strftime("%Y\-%m\-%d")
        end
      "<lastmod>#{value_lastmod}</lastmod>"
    end
    def balise_frequence_changement
      changefreq || (return '')
      "<changefreq>#{changefreq}</changefreq>"
    end

    def balise_video
      video? || (return '')
      <<-XML
      <video:video>
        <video:content_loc>#{video_loc}</video:content_loc>
        <video:player_loc allow_embed="yes">#{video_loc}</video:player_loc>
        #{balise_thumbnail_video}
        <video:title>#{video_title}</video:title>
        <video:description>#{video_description}</video:description>
      </video:video>
      XML
    end

    def balise_thumbnail_video
      video_thumbnail || (return '')
      "\n<video:thumbnail_loc>#{video_thumbnail}</video:thumbnail_loc>"
    end

  end #/Location
end #/SiteMap
