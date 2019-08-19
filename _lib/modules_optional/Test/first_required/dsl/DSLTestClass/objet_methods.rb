# encoding: UTF-8
class DSLTestMethod

  # Instance SiteHtml::TestSuite::HTML qui permet de
  # tester le code retourné dernièrement
  #
  # Noter que ça n'est possible qu'avec une test-méthode de
  # type "route", c'est-à-dire qui donne une route dans ses
  # données.
  #
  # Noter que l'instance est consignée dans une variable
  # d'instance, donc elle doit être ré-initialisée par
  # toute méthode qui rechargerait un code différent.
  #
  # On peut appliquer à cette instance toutes les méthodes de
  # type `has_message`, `has_tag`, etc.
  #
  def html
    raise (error_no_test_route "html") unless route_test?
    @html ||= SiteHtml::TestSuite::HTML::new(self, nokogiri_html)
  end

  # Une instance de dossier à tester
  def tfolder(path, name = nil)
    SiteHtml::TestSuite::TFolder.new path, name
  end

  # Une instance de fichier à tester
  def tfile(path, name = nil)
    SiteHtml::TestSuite::TFile.new(path, name)
  end


end
