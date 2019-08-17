=begin

  Essai des routes raccourcies

=end
feature "Les raccourcis sont utilisables" do
  scenario 'home conduit à l’accueil' do
    test 'La route-raccourci “home” conduit à l’accueil'
    visite_route 'home'
    La feuille contient le div 'presentation_atelier'

    test 'La route-raccourci “accueil conduit à l’accueil'
    visite_route 'accueil'
    La feuille contient le div 'presentation_atelier'
  end

  scenario '“signup” conduit au formulaire d’inscript' do
    test 'La route-raccourci “signup” conduit au formulaire d’inscription'
    visite_route 'signup'
    La feuille a pour titre 'Candidature Icare'

    test 'La route-raccourci “inscription” conduit au formulaire d’inscription'
    visite_route 'inscription'
    La feuille a pour titre 'Candidature Icare'
  end

  scenario 'La route-raccourci `bureau`, quand on est identifié, conduit à son bureau' do
    test 'Quand identifié, la route-raccourci `bureau` conduit à son bureau'
    identify_benoit
    visite_route 'accueil'
    La feuille contient le div 'presentation_atelier'
    visite_route 'bureau'
    La feuille a pour titre TITRE_BUREAU
  end

  scenario '`overview` conduit à la présentation de l’atelier' do
    test 'La route-raccourci `overview` conduit à la présentation de l’atelier'
    visite_route 'overview'
    La feuille a pour titre 'Présentation d’Icare'

    test 'La route-raccourci `apercu` conduit à la présentation de l’atelier'
    visite_route 'apercu'
    La feuille a pour titre 'Présentation d’Icare'
  end

  scenario '`aide` conduit à la présentation de l’atelier' do
    test 'La route-raccourci `aide` conduit à la table des matières de l’aide'
    visite_route 'aide'
    La feuille a pour titre 'Aide du site'
  end

  scenario '`contact` conduit à la présentation de l’atelier' do
    test 'La route-raccourci `contact` conduit au formulatire de contact'
    visite_route 'contact'
    La feuille a pour titre 'Contact'
  end

  scenario '`modules` conduit à la liste des modules' do
    test 'La route-raccourci `modules` conduit à la liste des modules'
    visite_route 'modules'
    La feuille a pour titre 'Modules d’apprentissage'
    La feuille contient la liste 'listing_absmodules'
  end

  scenario '`quai_des_docs` conduit au Quai des docs' do
    test 'La route-raccourci `quai_des_docs` conduit au Quai des docs'
    visite_route 'quai_des_docs'
    La feuille a pour titre 'Quai des docs'

    test 'La route-raccourci `qdd` conduit au Quai des docs'
    visite_route 'qdd'
    La feuille a pour titre 'Quai des docs'
  end

end
