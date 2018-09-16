# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Méthodes de test pour les feuilles de test
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile


  def test_user ref_user, options=nil, &block
    i = SiteHtml::TestSuite::TestUser.new(self, ref_user, options, &block)
    i.line = get_line_in_caller(caller.first)
  end
  def test_form route, data_form=nil, options=nil, &block
    i = SiteHtml::TestSuite::TestForm::new self, route, data_form, options, &block
    i.line = get_line_in_caller(caller.first)
    i
  end
  def test_route route, options=nil, &bloc
    i = SiteHtml::TestSuite::TestRoute::new( self, route, options, &bloc )
    i.line = get_line_in_caller(caller.first)
  end
  def test_base table_specs, options=nil, &block
    i = SiteHtml::TestSuite::TestBase::TestTable::new(self, table_specs, options, &block)
    i.line = get_line_in_caller(caller.first)
  end
  alias :test_table :test_base

  # / Fin méthodes des tests
  # ---------------------------------------------------------------------

  # +fromfile+ ressemble à # "(eval):54:in `block (2 levels) in execute'"
  def get_line_in_caller( fromfile )
    rien, line, autre = fromfile.split(':')
    line
  end
end #/TestFile
end #/TestSuite
end #/SiteHtml
