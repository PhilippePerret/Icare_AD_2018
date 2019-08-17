=begin

  Test des choix de redirection après le login

=end
feature "Redirections après le login (suivant les préférences)" do
  before(:all) do
    benoit.reset_all
  end
  scenario 'Benoit trouve un menu pour définir sa redirection après identification' do
    test 'Benoit trouve un menu pour définir sa redirection après identification'
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    La feuille contient le menu 'prefs_goto_after_login'
  end

  scenario 'Benoit choisit de rejoindre l’accueil avec succès' do
    test 'Benoit choisit de rejoindre l’accueil avec succès'

    # === RÉGLAGES PRÉALABLES ===
    benoit.set_option(18, 3)
    # === VÉRIFICATIONS PRÉALABLES ===
    expect(benoit.pref_goto_after_login).to eq 3

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'Accueil du site', dans: "#{form_jid} select#prefs_goto_after_login"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    expect(benoit.pref_goto_after_login).to eq 0

    # = VÉRIFICATION =
    Benoit clique le link 'Déconnexion'

    identify_benoit
    La feuille contient le div 'presentation_atelier'

  end


  scenario 'Benoit choisit de rejoindre son bureau de travail avec succès' do
    test 'Benoit choisit de rejoindre son bureau de travail avec succès'

    # === RÉGLAGES PRÉALABLES ===
    benoit.set_option(18, 0)
    # === VÉRIFICATIONS PRÉALABLES ===
    expect(benoit.pref_goto_after_login).to eq 0

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'Bureau de travail', dans: "#{form_jid} select#prefs_goto_after_login"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    expect(benoit.pref_goto_after_login).to eq 1

    # = VÉRIFICATION =
    Benoit clique le link 'Déconnexion'

    identify_benoit
    La feuille a pour titre TITRE_BUREAU

  end

  scenario 'Benoit choisit de rejoindre son profil avec succès' do
    test 'Benoit choisit de rejoindre son profil avec succès'

    # === RÉGLAGES PRÉALABLES ===
    benoit.set_option(18, 0)
    # === VÉRIFICATIONS PRÉALABLES ===
    expect(benoit.pref_goto_after_login).to eq 0

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'Profil', dans: "#{form_jid} select#prefs_goto_after_login"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    expect(benoit.pref_goto_after_login).to eq 2

    # = VÉRIFICATION =
    Benoit clique le link 'Déconnexion'

    identify_benoit
    La feuille a pour titre TITRE_PROFIL

  end


  scenario 'Benoit choisit de rejoindre sa dernière page consultée avec succès' do
    test 'Benoit choisit de rejoindre sa dernière page consultée avec succès'

    # === RÉGLAGES PRÉALABLES ===
    benoit.set_option(18, 0)
    # === VÉRIFICATIONS PRÉALABLES ===
    expect(benoit.pref_goto_after_login).to eq 0

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'Dernière page consultée', dans: "#{form_jid} select#prefs_goto_after_login"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    expect(benoit.pref_goto_after_login).to eq 3

    # = VÉRIFICATION =
    Benoit clique le link 'Déconnexion'

    identify_benoit
    La feuille a pour titre TITRE_PROFIL

    Benoit clique le link 'AIDE'
    La feuille a pour titre 'Aide du site'
    Benoit clique le link 'Poser sa candidature'
    La feuille a pour titre 'Aide du site'
    La feuille contient la balise 'h3', text: 'Poser sa candidature à l\'atelier'

    Benoit clique le link 'Déconnexion'

    # = TEST =
    identify_benoit
    La feuille a pour titre 'Aide du site'
    La feuille contient la balise 'h3', text: 'Poser sa candidature à l\'atelier'

  end

end
