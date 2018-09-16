# encoding: UTF-8
=begin

  Instance SiteHtml::TestSuite::TestBase::TestTable::Row
  ------------------------------------------------------
  Une rangée de table

=end
class SiteHtml
class TestSuite
class TestBase
class TestTable
class Row

  # {SiteHtml::TestSuite::TestBase::TestTable} Table de la base de
  # donnée contenant la rangée spécifiée (ou non)
  attr_reader :ttable

  # {Hash} Données spécifiant la rangée concernée
  attr_reader :specs

  # {Hash} Options (non utilisées pour le moment)
  attr_reader :options

  # Instanciation
  # +tbase+ {SiteHtml::TestSuite::TestBase} Table
  def initialize ttable, specs, options=nil
    @ttable   = ttable
    @specs    = specs
    @options  = options
    check_validity_or_raise
  end

  # Méthode qui checke la validité des spécifications de
  # la rangée et produit une exception s'il y a un problème.
  # Cette procédure permet notamment de ne pas avoir de définition
  # de colonne vide.
  def check_validity_or_raise
    return if specs.nil? || specs.empty?
    specs.each do |k, v|
      v == nil || next
      raise "[#{self.class} Impossible d'avoir une valeur nil (clé #{k.inspect})"
    end
  end

end #/Row
end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
