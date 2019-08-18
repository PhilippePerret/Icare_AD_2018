# encoding: UTF-8
class SiteMap
  class Location

    def tutoriels_videos
      require './_objet/video/DATA_VIDEOS.rb'
      @is_video = true
      Video::DATA_VIDEOS.collect do |vid, vdata|
        @url          = "video/#{vid}/show"
        @full_url     = nil
        @video_title  = vdata[:titre]
        @video_loc    = "https://www.youtube.com/embed/#{vdata[:ref]}"
        @video_description = vdata[:description]
        @lastmod      = vdata[:date_inv]
        @priority     = vdata[:priority]
        simple_as_xml
      end.join("\n")
      # /Fin boucle sur chaque vidéo
    end
    # /tutoriels_videos
  end #/Location
end #/SiteMap
