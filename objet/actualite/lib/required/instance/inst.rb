# encoding: UTF-8
class SiteHtml
class Actualite

  include MethodesMySQL

  attr_reader :id
  attr_reader :data

  # On peut instancier une actualité soit avec son identifiant seulement
  # soit avec son identifiant et ses données (quand on les relève d'une
  # base de données par exemple)
  def initialize aid, adata = nil
    @id   = aid
    @data = data
    adata.nil? || adata.each{|k,v|instance_variable_set("@#{k}",v)}
  end

  def table; @table ||= self.class.table end

end #/Actualite
end #/SiteHtml
