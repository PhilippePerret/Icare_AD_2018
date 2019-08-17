# encoding: UTF-8
=begin

  Module ChaineMethod
  -------------------

  Pour pouvoir utiliser des formules telles que :

    La feuille a pour titre 'mon titre'

    La feuille contient le formulaire 'id-du-formulaire'

  etc.


  MÉTHODES DISPONIBLES
  --------------------

    La feuille a pour titre 'mon titre'
    La feuille contient le titre 'mon titre'

    La feuille contient le formulaire 'id-formulaire'
    La feuille contient le lien 'titre lien', href: 'href'
    La feuille contient la liste 'id-de-liste-ul'
    La feuille contient le bouton 'nom du bouton'[, options]
    La feuille contient la balise 'tag'[, options]

    = Messages =

    La feuille affiche 'un texte'
    La feuille affiche le message erreur 'message erreur'
    La feuille affiche le message 'message'

=end
class ChaineMethod

  include RSpec::Matchers

  attr_reader :words
  attr_reader :options, :args

  def initialize args = nil, options = nil
    @args     = args
    @options  = options
  end

  # Ajout d'un mot à la chaine (inversée)
  def << mot
    @words ||= Array.new
    @words << mot
    return self
  end

  # Évaludation de la chaine
  def evaluate
    if args
      send(method_name, args, options)
    else
      send(method_name, options)
    end
  end
  def method_name; @method_name ||= words.reverse.join('_') end
end
