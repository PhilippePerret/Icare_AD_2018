# encoding: UTF-8
=begin

  Méthodes fonctionnelles dont peuvent hériter tous les
  modules contenant des "case-méthodes"
  (cf. la définition)

=end
module ModuleCaseTestMethods

  # Pour savoir s'il faut débugguer
  def debug?; SiteHtml::TestSuite::debug? end
  def start_debug ; SiteHtml::TestSuite::start_debug  end
  def stop_debug  ; SiteHtml::TestSuite::stop_debug   end

  # Pour traiter les méthodes plurielles. Envoyer simplement les
  # deux arguments attendus à cette méthode, plus la méthode de
  # traitement
  # Par exemple, pour la méthode `has_tags` :
  #   evaluate_as_pluriel :has_tag, ['div#mon', 'div#ton']
  #
  # Si +options+ est défini, c'est un hash de options générales
  # qui doivent être transmises à chaque élément.
  # Noter que dans ce cas, les éléments de +arr+ ne doivent pas
  # définir d'options en dernier argument, sinon ces options
  # générales seraient ajoutées comme argument supplémentaires
  # et entraineraient un bug.
  #
  # La méthode retourne le résultat de l'évaluation
  # dans le cas où ce sont des méthodes-?.
  #
  # +inverse+ permet de savoir si c'est une méthode not ou droite.
  # Car le comportement n'est pas du tout le même :
  #   * Si c'est une méthode droite (affirmative), la condition
  #     est vraie si tous les éléments existent et sont conformes
  #     Par exemple : has_tags
  #   * Si c'est une méthode inverse (négative), la condition est
  #     false dès qu'un élément correspond à la recherche.
  #     Par exemple : has_not_tags
  #
  def evaluate_as_pluriel method, arr, options=nil, inverse=false

    is_interrogative = method.to_s.end_with?("?")

    # Les éléments de la liste peuvent être :
    #   - soit un string seul (le premier argument de la méthode +method+)
    #   - soit un array définissant les arguments à envoyer à la
    #     méthode +method+
    # Mais peu importe car le `*` transforme en liste whatever il
    # reçoit, un élément seul ou une liste.
    #
    res = arr.collect do |args|
      unless options.nil?
        args = [args] unless args.instance_of?(Array)
        args << options
      end

      send(method, *args) # c'est le résultat qu'on doit collecter

    end.compact.uniq

    return res == [true]
  end

end

# On inclut ce module à DSLTestMethod
if defined?(DSLTestMethod)
  class DSLTestMethod; include ModuleCaseTestMethods end
end
