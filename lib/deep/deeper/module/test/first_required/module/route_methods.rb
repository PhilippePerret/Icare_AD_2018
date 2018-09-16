# encoding: UTF-8
=begin

Module contenant les méthodes pour les routes, utile par exemple aux
tests des pages (des routes) et des formulaires.

REQUIS

  L'objet-case qui utilise ces méthodes doit impérativement définir :

    - raw_route     Variable d'instance contenant la route entière
                    même avec son query-string.

=end
module ModuleRouteMethods

  # URL_PORT = ":1234"
  URL_PORT = ""

  require 'nokogiri'
  require 'open-uri'

  # {String} La route pour rejoindre le formulaire
  attr_reader :raw_route

  # Surclasse la même méthode dans DSLTestMethod pour indiquer
  # que la test-méthode courante — qui charge ce module — est
  # de type "route" et qu'elle peut donc utiliser `html` qui
  # permet d'accéder à toutes les méthodes qui testent le code
  # retourné par une route.
  def route_test?
    true
  end

  # Produit un succès si la route retourne une page 200,
  # produit une failure dans le cas contraire.
  #
  def responds options = nil, inverse = false

    # === TEST ===
    result = request(request_only_header).ok? # code 200

    # Simple retour de résultat (méthode?)
    return result if options!=nil && !options[:evaluate]

    # On crée un nouveau cas de méthode
    SiteHtml::TestSuite::Case::new(
      self,
      result:         result,
      positif:        !inverse,
      on_success:     "La page existe.",
      on_success_not: "La page n'existe pas (OK).",
      on_failure:     "La page devrait exister.",
      on_failure_not: "La page ne devrait pas exister."
    ).evaluate

  end

  def responds? options = nil
    responds( (options||{}).merge(evaluate: false) )
  end
  def not_responds options = nil
    responds options, true
  end


  # RETURN Une instance SiteHtml::TestSuite::Html qui permettra
  # de faire tous les tests sur le code HTML avec Nokogiri
  def instance_test_html
    @instance_test_html ||= SiteHtml::TestSuite::HTML::new(nokogiri_html)
  end

  # def nokogiri_html
  #   @nokogiri_html ||= begin
  #     debug "JE PASSE PAR CE nokogiri_html LÀ"
  #     Nokogiri::HTML( open url )
  #   end
  # end

  # Redéfinir le Nokogiri::HTML suite à une nouvelle requête,
  # pour prendre en compte le nouveau code.
  def nokogiri_html= valeur
    @nokogiri_html = valeur
    # Pour forcer l'actualisation du code
    @instance_test_html = nil
  end

  # URI
  # Soit la route brute si elle commence par 'http' soit la
  # route préfixé de la base-uri en fonction du lieu online/offline
  # et du port.
  def url
    @url ||= begin
      if raw_route.start_with?('http')
        raw_route
      else
        "#{SiteHtml::TestSuite::current::base_url}#{URL_PORT}/#{raw_route}"
      end
    end
  end

  # Pour obtenir une URL qu'on peut cliquer, pour l'affichage du
  # libellé de la test-méthode
  def clickable_url
    @clickable_url ||= url.in_a(class:'inherit', href: url, target: :new)
  end

  def request req
    SiteHtml::TestSuite::Request::new(req).execute
  end
  def request_only_header
    @request_only_header  ||= "curl -I #{url}"
  end
  def request_whole_page
    @request_whote_page   ||= "curl #{url}"
  end

end
