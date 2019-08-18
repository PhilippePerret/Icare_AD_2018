# encoding: UTF-8
raise_unless_admin
=begin

  Fabrication/actualisation de la sitemap

=end
require 'yaml'
site.require_all_in('./_objet/site/sitemap')

class SiteMap
  include Singleton

  include MethodesMainObjet

  attr_reader :nombre_total_urls

  MAX_URLS      = 50000
  MAX_FILE_SIZE = 10000000
  # = main =
  #
  # Méthode principale pour fabriquer la sitemap
  def built
    path.exist? && path.remove
    path.write xml_code
  end


  def yaml_data
    @yaml_data ||= YAML.load_file(yaml_file)
  end
  def yaml_file
    @yaml_file ||= _('sitemap.yaml')
  end
  def path
    @path ||= SuperFile.new(['.', 'sitemap.xml'])
  end

end #/SiteMap

def sitemap
  @sitemap ||= SiteMap.instance
end

sitemap.built
