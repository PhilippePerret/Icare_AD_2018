# encoding: UTF-8
require 'levenshtein'

class TString < String

  attr_reader :tmethod

  # {Array} Erreurs rencontrées au cours du test, pour
  # indiquer la raison de l'échec, if any.
  attr_reader :errors

  # +tmethod+ Test-méthode appelante. Utilise pour savoir
  # où enregistrer les succès et les failures.
  # +str+ {String} Valeur à donner au string
  def initialize tmethod, str=nil
    @tmethod  = tmethod || SiteHtml::TestSuite::TestFile::current_test_method
    @errors   = []
    super(str)
  end


  # ---------------------------------------------------------------------
  #   has, has_not, has?, has_not?
  # ---------------------------------------------------------------------

  # Méthode principale testant la correspondance entre le
  # string est +searched+
  #
  # +searched+
  #   {String|Array of String} Le texte recherché, soit
  #   seul, soit un array de strings à trouver.
  #
  # +options+
  #   :strict   Si true, recherche strict sur le string
  #   :sujet    Nom humain du sujet, pour un message plus clair
  #   :objet    Nom humain de l'objet, pour un message plus clair
  #
  # Noter que si searched est un array :
  #   Si inverse est false (droit), le string doit contenir tous
  #   les textes. => boucle sur tous les tests
  #   Si inverse est true (inverse), le string ne doit contenir
  #   aucun des textes. => Un seul manque produit une erreur
  #
  def has searched, options=nil, inverse=false
    options ||= {}

    strict = options[:strict]

    ok = self_contains( searched, inverse, strict)

    is_success = ok == !inverse

    # En cas de simple évaluation
    options[:evaluate] && ( return is_success )

    str_expected = searched.inspect
    sujet_str = options[:sujet]   || "“#{self}”"
    objet_str = options[:objet]   || "#{searched.inspect}"

    # Ici, on a plutôt intérêt à composer seulement le
    # message de résultat nécessaire
    mess =
      if is_success
        if inverse
          "#{sujet_str} #{strict ? 'n’est pas égal à' : 'ne contient pas'} #{objet_str} (OK)"
        else
          "#{sujet_str} #{strict ? 'est égal à' : 'contient'} #{objet_str}"
        end
      else
        devrait = inverse ? 'ne devrait pas' : 'devrait'
        "#{sujet_str} #{devrait} #{strict ? 'être égal à' : 'contenir'} #{objet_str}."
      end

    # Production du cas
    SiteHtml::TestSuite::Case::new(
      tmethod,
      result:         ok,
      message:        mess
    ).evaluate
  end

  def has_not searched, options=nil
    has searched, options, true
  end
  def has? searched, options=nil
    has searched, (options || {}).merge(evaluate: true)
  end
  def has_not? searched, options=nil
    has searched, (options || {}).merge(evaluate: true), true
  end


  # ---------------------------------------------------------------------
  #   is, is_not, is?, is_not?
  # ---------------------------------------------------------------------
  def is expected, options=nil, inverse=false
    has expected, (options || {}).merge(strict: true), inverse
  end
  def is_not expected, options=nil
    is expected, options, true
  end
  def is? expected, options=nil
    is expected, (options || {}).merge(evaluate: true)
  end
  def is_not? expected, options=nil
    is expected, (options || {}).merge(evaluate: true), true
  end

  # ---------------------------------------------------------------------
  #  Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Retourne true si le string courant contient la liste
  # des messages contenu dans +arr+ et que c'est un test
  # droit (inverse = false).
  #
  # Si +strict+ est true, la recherche doit être exacte.
  #
  # +arr+ peut être un texte seul ou un Regexp
  def self_contains arr, inverse, strict
    arr = [arr] unless arr.instance_of?(Array)

    # debug "\n\n-> TString#self_contains"
    # debug "   self = #{Debug::escape self}"
    # debug "   arr  = #{Debug::escape arr}"

    met_error = false
    arr.each do |expected|

      # debug "  * expected = #{Debug::escape expected} (strict: #{strict.inspect})"

      unless expected.instance_of?(Regexp)
        expected = strict ? /^#{Regexp::escape expected}$/ : /#{Regexp::escape expected}/i
      end
      if self =~ expected
        # Le texte a été trouvé, ça provoque une erreur
        # si test inverse
        # debug "  = expected TROUVÉ"
        if inverse
          errors << "ne devrait pas contenir “#{expected.source}”"
          met_error = true
        end
      else
        # Le texte n'a pas été trouvé, ça provoque une
        # erreur si test droit
        ndl = Levenshtein.normalized_distance(self, expected.source)
        # debug "  = expected NON TROUVÉ (distance : #{ndl})"
        # Distance de Levenshtein
        if !inverse
          errors << "devrait contenir “#{expected.source}”"
          met_error = true
        end
      end
    end
    return !met_error
  end

end
