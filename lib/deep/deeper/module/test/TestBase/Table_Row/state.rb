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

  def online?
    @is_online ||= SiteHtml::TestSuite::online?
  end
  
end #/Row
end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
