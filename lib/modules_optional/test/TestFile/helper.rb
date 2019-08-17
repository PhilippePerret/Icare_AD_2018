# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Méthode d'helper d'une instance d'un fichier de test
#
# ---------------------------------------------------------------------
site.require_module('Kramdown')

class SiteHtml
class TestSuite
class TestFile

  # Retourne la première ligne à marquer au-dessus du
  # rapport de test
  def line_output itestfile
    c = (
      "#{itestfile}- #{clickable_path}" +
      description_formated
      ).in_div(class:'pfile')
  end

  # On formate la description à l'aide de Kramdown
  def description_formated
    description || (return "")
    Kramdown::Document.new(description).send(:to_html)
  end

end #/TestFile
end #/TestSuite
end #/SiteHtml
