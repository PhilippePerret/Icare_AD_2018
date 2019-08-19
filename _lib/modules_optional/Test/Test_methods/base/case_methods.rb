# encoding: UTF-8
=begin

  Case-méthodes pour test_base

=end
class SiteHtml
class TestSuite
class TestBase
class TestTable < DSLTestMethod

  # Une rangée de la table (existant ou non)
  # Retourne le case-objet d'attributs +attrs+
  # +attrs+ sont les données des colonnes qui permettront de
  # retrouver la rangée
  def row attrs = nil
    SiteHtml::TestSuite::TestBase::TestTable::Row::new(self, attrs)
  end

  # Produit un succès si la rangée spécifiée par +attrs+
  # existe (ou si la table contient au moins une rangée si
  # attrs est nil) ou une failure dans le cas contraire.
  # Test en fonction du type de +attrs+
  #   - si nil => test pour savoir si la table contient une rangée
  #   - si hash => test sur la rangée spécifiée
  #   - si fixnum => test du nombre de rangées
  def has_row attrs = nil, inverse=false
    row(attrs).exists(inverse)
  end
  def has_not_row attrs = nil
    has_row(attrs, true)
  end
  # Retourne true si la rangée spécifiée par +attrs+
  # existe ou si la table a une rangée si attrs est nil
  # Retourne false dans le cas contraire.
  def has_row? attrs=nil
    row(attrs).exists?
  end


end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
