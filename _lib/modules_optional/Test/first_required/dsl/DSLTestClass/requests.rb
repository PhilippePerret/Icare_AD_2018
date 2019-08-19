# encoding: UTF-8
=begin

Module contenant tout ce qui concerne les requêtes serveur, donc
principalement Nokogiri et cURL

=end

class DSLTestMethod

  # Instance `Nokogiri::HTML` du code de retour de l'url.
  #
  # Note : `url` ci-dessous est une méthode du module ModuleRouteMethods
  # qui le compose en fonction de l'url de base (distant ou local) et
  # la route de la test-méthode courante
  #
  # Une erreur est produite si la test-méthode courante n'est pas de
  # type "route-test" (i.e. ne charge pas le module ModuleRouteMethods)
  #
  def nokogiri_html
    @nokogiri_html ||= begin
      route_test? || raise(error_no_test_route "nokogiri_html")
      # Je vais essayer avec cUrl quand même pour pouvoir
      # conserver les variables session et cookies
      request_curl = SiteHtml::TestSuite::Request::CURL.new(self)
      request_curl.execute
      request_curl.nokogiri_html
      # open_doc = open(url, nil, curl_request.header[:cookies])
      # Nokogiri::HTML(open url)
    end
  end

end
