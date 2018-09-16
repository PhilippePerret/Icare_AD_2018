=begin

  Test du bureau d'un icarien actif

=end
feature "Test du bureau d'un actif" do
  before(:all) do
    benoit.set_actif(
      since:    10,
      module:   7,
      etape:    10
    )
    dwatcher = {
      objet:      'bureau',
      processus:  'test_watcher'
      }
    @wid = (benoit.has_watcher?(dwatcher) || benoit.add_watcher(dwatcher))
  end
  scenario "Un actif trouve un bureau conforme" do
    test 'En rejoignant l’atelier, Benoit trouve un bureau conforme.'
    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    La feuille contient la balise 'span', class: 'user_state', text: 'actif'
    La feuille contient le fieldset 'infos_current_module',
      success: 'Le bureau affiche les informations sur le module courant'
    La feuille contient le fieldset 'fs_etape_courante',
      success: 'Le bureau affiche les informations sur l’étape courante'
    La feuille contient la balise 'p', id: 'bureau_cadre_explication_travail'
    La feuille contient le link 'Votre travail', href: 'bureau/home#travail_etape',
      success: 'Le bureau présente un bouton au-dessus pour rejoindre le travail en bas de page'
    La feuille contient la liste "watchers-user-#{benoit.id}", class: 'notifications',
      success: 'Le bureau contient la liste des notifications courantes'
    La feuille contient la balise 'li', id: "li_watcher-#{@wid}", dans: "ul#watchers-user-#{benoit.id}",
      success: 'Le bureau présente la notification pour test'
    La feuille contient le fieldset 'current_etape_work',
      success: 'Le bureau contient le fieldset pour le travail courant'
  end
end
