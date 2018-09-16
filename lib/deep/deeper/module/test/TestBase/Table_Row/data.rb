# encoding: UTF-8
=begin

  Instance SiteHtml::TestSuite::TestBase::TestTable::Row
  ------------------------------------------------------
  Une rangée de table

=end
require 'sqlite3'

class SiteHtml
class TestSuite
class TestBase
class TestTable
class Row

  # {THash} Retourne les données de la rangée spécifiée
  # C'est une instance THash qui est un Hash augmenté des
  # méthodes de test comme `has`.
  #
  # Noter qu'elles sont récupérées à chaque fois, donc
  # qu'il faut les dupliquer dans une donnée pour les
  # tester sans les recharger à chaque fois depuis la table
  #
  # Cette méthode sert dans les tests de cette manière :
  #
  #   row(12).data.has(id: 12)
  #
  # ou
  #
  #   d12 = row(12).data
  #   d12.has(id: 12)
  #
  # Mais la FORMULE PRÉFÉRÉE est d'utiliser les méthodes
  # de tests directement sur la rangée :
  #
  #   row(12).has(id: 12)
  #
  def data options=nil
    req = SiteHtml::TestSuite::TestBase::Request::new(self, options)
    retour_request = req.first_resultat
    THash.new(ttable).merge!(retour_request || {})
  end

  # Permet de définir des valeurs dans la rangée courante
  def set hdata
    req = SiteHtml::TestSuite::TestBase::Request::new(self)
    req.execute( req.set_request(hdata) )
  end


end #/Row
end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
