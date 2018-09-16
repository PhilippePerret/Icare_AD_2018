# encoding: UTF-8
=begin

SiteHtml::Test::Html

Pour le traitement des codes Html

=end
class SiteHtml
class TestSuite
class HTML

  # Test-method
  # Une classe héritant de DSLTestMethod
  attr_reader :tmethod

  # {String} Le code tel qu'il est soumis à l'instanciation
  # Il sera aussi transformé en instance Nokogiri::HTML
  attr_reader :raw_code

   # {Nokogiri::HTML::Document}
  # Utiliser `page` plutôt
  attr_reader :nokogiri_html_doc

  # Argument : Soit du code HTML brut, soit (meilleur) un
  # Nokogiri::HTML::Document
  #
  # +tmethod+   La test-méthode courante
  def initialize tmethod, rawhtml_or_nokohtml
    @tmethod = tmethod
    @nokogiri_html_doc = case rawhtml_or_nokohtml
    when Nokogiri::HTML::Document
      rawhtml_or_nokohtml
    when String
      @raw_code = rawhtml_or_nokohtml
      ( Nokogiri::HTML rawhtml_or_nokohtml )
    else
      raise "Mauvais format pour l'instanciation de SiteHtml::Test::Html : #{rawhtml_or_nokohtml.class} (String ou Nokogiri::HTML::Document attendu)"
    end
  end

  # Raccourci
  def page ; @nokogiri_html_doc end


end #/Html
end #/TestSuite
end #/SiteHtml
