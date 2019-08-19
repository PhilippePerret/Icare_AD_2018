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

  # Raccourcis pour utiliser par exemple `row(...).has(...)`
  def has h, opts = nil      ; data.has(h, opts)       end
  def has_not h, opts = nil  ; data.has_not(h, opts)   end
  def has? h, opts = nil     ; data.has?(h, opts)      end
  def has_not? h, opts = nil ; data.has_not?(h, opts)  end

  def exists options=nil, inverse=false
    # debug "-> exists(inverse=#{inverse.inspect})"
    debug "   [Row#exists] data = #{data.inspect}"
    ok = data.nil_if_empty != nil

    lachose = "La rangée définie par #{specs.inspect}"

    # Production du cas
    SiteHtml::TestSuite::Case::new(
      ttable, # C'est la test-méthode
      result:         ok,
      positif:        !inverse,
      on_success:     "#{lachose} existe.",
      on_success_not: "#{lachose} n'existe pas (OK).",
      on_failure:     "#{lachose} devrait exister.",
      on_failure_not: "#{lachose} ne devrait pas exister."
    ).evaluate
  end
  def not_exists options=nil
    exists options, true
  end
  def exists?
    data != nil
  end
  alias :exist? :exists?

end #/Row
end #/TestTable
end #/TestBase
end #/TestSuite
end #/SiteHtml
