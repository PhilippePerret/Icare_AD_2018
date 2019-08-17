=begin

  Test de la conformité de la page d'accueil

=end
feature "Conformité de la page d'accueil" do

  scenario 'La page d’accueil est conforme' do
    visit_home
    # - Les sections -
    La feuille contient la section 'header'
    La feuille contient la section 'left_margin'
    La feuille contient la section 'content'
    La feuille contient la section 'footer'
    # - Les divs -
    La feuille contient le div 'presentation_atelier'
    La feuille contient le div 'div_last_actualites'
    La feuille contient le div 'citation'
    La feuille contient le div 'presentation_phil'
  end

  scenario 'Liens de la page d’accueil' do
    test 'La page d’accueil contient les bons liens'
    visit_home
    La feuille contient le link 'ACCUEIL', dans: 'section#left_margin'
    La feuille contient le link 'CONTACT', dans: 'section#left_margin'
    La feuille contient le link 'AIDE', dans: 'section#left_margin'
    La feuille contient le link 'Modules d’apprentissage', dans: 'div#boutons_icariens'
    La feuille contient le link 'RÉUSSITES', dans: 'div#boutons_icariens'
    La feuille contient le link 'TÉMOIGNAGES', dans: 'div#boutons_icariens'
    La feuille contient le link 'Présentation complète', dans: 'div#presentation_atelier'
    La feuille contient le link 'S\'identifier', dans: 'section#header'
    La feuille contient le link 'Poser sa candidature', dans: 'section#header'

    # On essaie tous ces liens
    Phil clique sur le link 'ACCUEIL'
    La feuille contient le div 'presentation_atelier'
    Phil clique sur le link 'ACCUEIL'
    Phil clique le link 'AIDE'
    La feuille a pour titre 'Aide du site'
    Phil clique sur le link 'ACCUEIL'
    Phil clique sur le link 'CONTACT'
    La feuille a pour titre 'Contact'
    Phil clique sur le link 'ACCUEIL'
    Phil clique sur le link 'Modules d’apprentissage'
    La feuille a pour titre 'Modules d’apprentissage'
    Phil clique sur le link 'ACCUEIL'
    Phil clique sur le link 'RÉUSSITES'
    La feuille a pour titre 'Présentation d’Icare'
    La feuille a pour soustitre 'Hall of Fame'
    Phil clique sur le link 'ACCUEIL'
    Phil clique sur le link 'TÉMOIGNAGES'
    La feuille a pour titre 'Présentation d’Icare'
    La feuille a pour soustitre 'Témoignages'
    Phil clique sur le link 'ACCUEIL'
    Phil clique le link 'Présentation complète'
    La feuille a pour titre 'Présentation d’Icare'
    La feuille a pour soustitre 'Présentation générale de l’atelier'
    Phil clique sur le link 'ACCUEIL'
    Phil clique le link 'S\'identifier'
    La feuille a pour titre 'Identification'
    Phil clique le link 'ACCUEIL'
    Phil clique le link 'Poser sa candidature'
    La feuille a pour titre 'Candidature Icare'
  end
end
