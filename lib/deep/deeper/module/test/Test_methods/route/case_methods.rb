# encoding: UTF-8
=begin

  Méthodes de test pour les routes

  @usage

      test_route "la/route" do |r|

        r.<methode>[ <paramètres>]
        r.<methode>[ <paramètres>]
        etc.

      end

=end
class SiteHtml
class TestSuite
class TestRoute < DSLTestMethod

  include ModuleRouteMethods

end #/Route
end #/TestSuite
end #/SiteHtml
