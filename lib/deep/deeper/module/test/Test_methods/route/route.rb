# encoding: UTF-8
=begin

  Pour tester une route, c'est-à-dire une page

  Ce sont les méthodes fonctionnelles. Pour voir les méthods
  utilisables dans les tests, cf. le module `test_methods.rb`

=end

class SiteHtml
class TestSuite
class TestRoute < DSLTestMethod

  # attr_reader :raw_route

  # +raw_route+ La route brut, qui peut contenir un query_string
  def initialize __tfile, raw_route, options=nil, &block
    SiteHtml::TestSuite::current_test_method = self
    @raw_route = raw_route
    super(__tfile, &block)
  end

  def description_defaut
    @description_defaut ||= "TEST ROUTE #{clickable_url}"
  end

  # Le sujet de la test-méthode
  #
  # Cf. le manuel
  def subject
    @subject ||= html
  end
  
end #/Route
end #/TestSuite
end #/SiteHtml
