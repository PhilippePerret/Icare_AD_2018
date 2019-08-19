# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Une instance d'un fichier de test
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile
class << self

  # Instance de la Test-Méthode courante, utile par exemple
  # pour les TString ou les TInteger lorsqu'on fait :
  #   str = TString.new(self, "mon string")
  #   sousstr = str[3]  # <= un TString qui prendra la méthode self
  #
  # Elle est définie à l'instanciation de toute test-méthode dans
  # DSLTestClass
  attr_accessor :current_test_method


end #/<<self
end #/TestFile
end #/TestSuite
end #/SiteHtml
