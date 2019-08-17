# encoding: UTF-8
=begin

Instance d'un book LaTex

=end

# On charge toutes les librairies pour l'instance
Dir["#{FOLDER_LATEXBOOK}/latexbook/instance/**/*.rb"].each{|m| require m}
class LaTexBook

  # {String|SuperFile} Chemin d'accès au dossier du livre
  attr_reader :folder_path

  def initialize folder_path
    @folder_path = folder_path
    # Pour que la méthode `book`, qui permet de définir les données,
    # puisse faire référence à cette instance.
    self.class::current = self
  end

end #/LatexBook
