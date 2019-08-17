# encoding: UTF-8
=begin

  Ce module contient les méthodes utiles pour les tests mais qui
  ne sont pas des tests.

=end
class SiteHtml
class TestSuite
class TestBase
class TestTable

  # Case-méthode qui retourne le nombre de rangées dans
  # la table courante.
  def count( options=nil )
    req = SiteHtml::TestSuite::TestBase::Request::new(self, options)
    req.execute( req.count_request )
    # req.first_resultat contient quelque chose comme {:"COUNT(*)" => 12}
    req.first_resultat.values.first # contient
  end

end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
