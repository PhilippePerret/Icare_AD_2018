# encoding: UTF-8
class SiteHtml
class TestSuite
class TestForm < DSLTestMethod

  attr_reader :data_form

  def initialize(__tfile, raw_route, data_form = nil, options = nil, &block)
    SiteHtml::TestSuite::current_test_method = self
    @raw_route = raw_route
    @data_form = data_form
    super(__tfile, &block)
  end

  def description_defaut
    @description_defaut ||= begin
      fs =
        if data_form[:id]
          " ##{data_form[:id]}"
        elsif data_form[:name]
          " .#{data_form[:name]}"
        else
          ""
        end
      "TEST FORM#{fs} AT #{clickable_url}"
    end
  end

  # Le "sujet" de la test-méthode
  # C'est le node Nokogiri du formulaire
  def subject
    @subject ||= html.find("form#{form_specs}")
  end

  def form_specs
    @form_specs ||= begin
      attrs = ""
      attrs << "##{data_form[:id]}"     if data_form.key?(:id)
      attrs << ".#{data_form[:class]}"  if data_form.key?(:class)
      attrs << "[action=\"#{data_form[:action]}\"]" if data_form.key?(:action)
      attrs
    end
  end

end #/TestForm
end #/TestSuite
end #/SiteHtml
