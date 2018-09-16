# encoding: UTF-8
=begin

Test-méthode test_base

=end
class SiteHtml
class TestSuite
class TestBase
class TestTable < DSLTestMethod

  # {String} Spécification de la table telles que
  # fournies à l'instanciation
  attr_reader :table_spec

  # {Hash} Options transmises à l'instanciation
  attr_reader :options

  # Instanciation
  def initialize __tfile, table_spec, options=nil, &block
    SiteHtml::TestSuite::current_test_method = self
    @table_spec = table_spec
    @options    = options
    analyse_table
    super(__tfile, &block)
  end

  def description_defaut
    @description_defaut ||= "TEST TABLE #{name} DE BASE #{database.name}"
  end

  # Le sujet : AVANT : La table (BdD::Table)
  def subject
    @subject ||= begin
      raise "Il faut redéterminer subject avec MySQL"
    end
  end

  # On décompose la base et la table en testant la
  # validité des informations données
  def analyse_table
    dbase, table_name = table_spec.split('.')
    dbase       = dbase.nil_if_empty
    table_name  = table_name.nil_if_empty
    raise ERROR[:table_spec_invalid] if dbase.nil? || table_name.nil?
    @database = SiteHtml::TestSuite::TestBase::new(dbase)
    @database.exist? || raise(ERROR[:database_unfound] % [@database.path.to_s])
    @name = table_name
  end

  # {SiteHtml::TestSuite::TestBase} Base de données
  def database ; @database end
  # {String} La table concernée
  def name     ; @name     end

end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
