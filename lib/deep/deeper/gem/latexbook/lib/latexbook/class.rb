# encoding: UTF-8
require 'yaml'
require 'fileutils'

# Pour le moment, il faut requérir superfile avant
# require 'superfile'


# On charge toutes les librairies pour la classe
['class', 'extensions'].each do |sfold|
  Dir["#{FOLDER_LATEXBOOK}/latexbook/#{sfold}/**/*.rb"].each{|m| require m}
end
class LaTexBook
class << self

  # Instance {LaTexBook} courante (pour pouvoir être utilisée
  # avec la méthode `livre`).
  # Elle est définie par la dernière instanciation (c'est toujours
  # la dernière instance qui est l'instance courante)
  attr_accessor :current

  def version ; @version ||= "0.1" end

end #/<< self
end #/LatexBook
