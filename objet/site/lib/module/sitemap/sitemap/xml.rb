# encoding: UTF-8
class SiteMap

  def xml_code
    ENTETE_XML +
    xml_url_items +
    FOOTER_XML
  end
  def xml_url_items
    @nombre_total_urls = 0
    yaml_data.collect do |hloc|
      loc = Location.new(hloc)
      res = loc.as_xml
      @nombre_total_urls += loc.nombre_urls
      res
    end.join("\n")
  end

  ENTETE_XML = <<-XML
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
  xmlns:image="http://www.google.com/schemas/sitemap-image/1.1"
  xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
  XML
  FOOTER_XML = "</urlset>"

end #/SiteMap
