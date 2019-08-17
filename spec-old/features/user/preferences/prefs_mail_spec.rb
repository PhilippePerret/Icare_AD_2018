=begin

  Pour tester les préférences de mail

=end
feature "Un icarien peut définir ses préférences mail" do
  before(:all) do
    benoit.reset_all
  end

  scenario 'L’icarien trouve ses préférences de mails dans son profil' do

    identify_benoit

    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    La feuille contient le fieldset 'preferences'
    La feuille contient le formulaire 'form_preferences'
    form_jid = 'form#form_preferences'
    La feuille contient le menu 'prefs_mail_updates', dans: form_jid
  end

  scenario 'Benoit peut choisir de ne jamais recevoir de mail' do

    # === PRÉRÉGLAGE ===
    # On met le bit de Benoit dans une valeur différente
    benoit.set(options: benoit.options.set_bit(17,0))
    expect(benoit.pref_mails_activites).to eq 0
    expect(benoit.options[17]).to eq '0'

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'jamais', dans: "#{form_jid} select#prefs_mail_updates"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    ben = User.new(benoit.id)
    expect(ben.options[17]).to eq '1'
    expect(ben.pref_mails_activites).to eq 1
  end

  scenario 'Benoit peut choisir de recevoir les mails hebdomadairement' do
    test 'Benoit peut choisir de recevoir les mails hebdomadairement'
    # === PRÉRÉGLAGE ===
    # On met le bit de Benoit dans une valeur différente
    benoit.set(options: benoit.options.set_bit(17,0))
    expect(benoit.pref_mails_activites).to eq 0
    expect(benoit.options[17]).to eq '0'

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'une fois par semaine', dans: "#{form_jid} select#prefs_mail_updates"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    ben = User.new(benoit.id)
    expect(ben.options[17]).to eq '2'
    expect(ben.pref_mails_activites).to eq 2

  end

  scenario 'Benonit décide de recevoir les mails tous les jours' do
    test 'Benonit décide de recevoir les mails tous les jours'
    # === PRÉRÉGLAGE ===
    # On met le bit de Benoit dans une valeur différente
    benoit.set(options: benoit.options.set_bit(17,3))
    expect(benoit.pref_mails_activites).to eq 3
    expect(benoit.options[17]).to eq '3'

    # === TEST ===
    identify_benoit
    Benoit clique le link 'PROFIL'
    La feuille a pour titre TITRE_PROFIL
    form_jid = 'form#form_preferences'
    Benoit choisit 'tous les jours', dans: "#{form_jid} select#prefs_mail_updates"
    Benoit clique le bouton 'Enregistrer', dans: form_jid

    La feuille a pour titre TITRE_PROFIL
    La feuille affiche le message 'vos préférences sont enregistrées'

    ben = User.new(benoit.id)
    expect(ben.options[17]).to eq '0'
    expect(ben.pref_mails_activites).to eq 0

  end
end
