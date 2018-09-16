# encoding: UTF-8
=begin

  Méthodes qui augmentent la méthode générale `debug' pour
  faire des débuggages propres aux tests


=end
class DSLTestMethod

  alias :top_debug :debug
  def debug(foo, options=nil)
    case foo
    when SiteHtml::TestSuite::HTML
      debug_html html, options
    else
      top_debug foo
    end
  end

  def debug_html ihtml, options=nil
    options ||= {}
    c = ihtml.page.inner_html
    options[:head] || c.sub!(/<head(.*)<\/head>/, '')
    options[:body] === false && c.sub!(/<body(.*)<\/body>/, '')
    if options[:left_margin] === false
      c.sub!(/<section id="left_margin"(.*)<\/section>/, '')
    end
    if options[:right_margin] === false
      c.sub!(/<section id="right_margin"(.*)<\/section>/, '')
    end
    top_debug "\n\n=== CODE DE LA PAGE ===\n\n" +
              c.gsub(/</,'&lt;') +
              "\n\n=== /CODE PAGE ===\n\n\n"
  end

end
