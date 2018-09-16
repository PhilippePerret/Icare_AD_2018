# encoding: UTF-8
class LaTexBook
class << self

  # Méthode pour ajouter un message d'erreur
  # @syntaxe    LaTexBook.error <message d'erreur ou erreur>
  def error err
    @errors ||= Array::new
    @errors << err
  end

end #/<<self
end #/LatexBook
