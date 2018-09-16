# encoding: UTF-8

feature "Inscription d'un user" do
  def data_signup
    @data_signup ||= begin
      pseudo = random_pseudo
      umail  = "#{pseudo.downcase}@chez.com"
      {
        _prefix:            'user_',
        pseudo:             pseudo,
        mail:               umail,
        mail_confirmation:  umail,
        naissance:  {type: :select, value: 1970 + rand(10)},
        sexe:   {type: :select, value: 'un homme'},
        password: "monmotdepasse",
        password_confirmation: "monmotdepasse",
        captcha: 366
      }
    end
  end
  before(:all) do
    benoit.reset_all
  end
  scenario "Un user peut trouver le formulaire d'inscription" do
    test 'Benoit peut trouver le formulaire d’inscription'
    visit_home
    La feuille contient la section 'header'
    La feuille contient le link 'Poser sa candidature'
    La feuille contient le link 'S\'identifier'
    shot 'accueil'
    Benoit clique le link 'Poser sa candidature'
    La feuille a pour titre 'Candidature Icare'
    La feuille ne contient pas le link 'Poser sa candidature'
    La feuille contient le link 'S\'identifier'
    La feuille contient le formulaire 'form_user_signup'
    La feuille contient le div 'bandeau_states'
    la feuille contient la balise 'div.selected', dans: 'div#bandeau_states'
  end


  scenario 'Benoit remplit le formulaire d’inscription et le soumet' do

    test 'Benoit remplit le formulaire d’inscription et le soumet'

    start_time = Time.now.to_i - 1
    upseudo = data_signup[:pseudo]
    umail   = data_signup[:mail]

    nb = User.table.count(where: {pseudo: upseudo})
    expect(nb).to eq 0
    success "#{upseudo} n'est pas inscrit."


    visit_home
    benoit.clique_le_lien('Poser sa candidature')
    La feuille a pour titre 'Candidature Icare'
    La feuille contient le formulaire 'form_user_signup'
    x = page.execute_script("return $('span#xcap').html()").to_i
    y = page.execute_script("return $('span#ycap').html()").to_i
    captcha_value = (x + y).to_s
    # puts "x = #{x}, y = #{y}, captcha_value = #{captcha_value}"

    form_id = 'form_user_signup'
    form_jid = "form##{form_id}"
    benoit.remplit_le_formulaire(form_id).
      avec(data_signup.merge(captcha: captcha_value))

    Benoit clique le bouton 'Enregistrer et poursuivre l’inscription', dans: form_jid

    # === PREMIÈRES VÉRIFICATIONS ===
    La feuille a pour titre 'Candidature Icare'

    # L'user n'a pas encore été créé dans la table
    nb = dbtable_users.count(where: {pseudo: data_signup[:pseudo]})
    expect(nb).to eq 0
    success 'Le candidat n’est pas encore créé.'

    # Un dossier a été créé avec le numéro de session
    # Attention : ça ne fonctionne qu'en OFFLINE
    session_id = cpage.execute_script('return SESSION_ID;')
    session_id != nil || raise('Impossible d’atteindre le numéro de session')
    signup_folder = site.folder_tmp+"signup/#{session_id}"
    path_identite = signup_folder + "identite.msh"
    expect(path_identite).to be_exist
    success 'Le fichier des données d’identité a été enregistré'

    start_time = Time.now.to_i

    # ---------------------------------------------------------------------
    #   Deuxième partie de l'inscription - module d'apprentissage
    # ---------------------------------------------------------------------
    La feuille contient la liste 'abs_modules'

    # Benoit choisi trois modules
    Benoit coche le checkbox 'signup_modules-2', dans: 'li#absmodule-2'
    Benoit coche le checkbox 'signup_modules-4', dans: 'li#absmodule-4'
    Benoit coche le checkbox 'signup_modules-6', dans: 'li#absmodule-6'

    La feuille contient la balise 'input', id: 'signup_modules-2', checked: true, dans: 'li#absmodule-2'
    La feuille ne contient pas la balise 'input', id: 'signup_modules-1', checked: true, dans: 'li#absmodule-1'

    Benoit clique le bouton 'Enregistrer et poursuivre l’inscription'

    La feuille a pour titre 'Candidature Icare'
    La feuille contient le formulaire 'form_documents'

    # ---------------------------------------------------------------------
    #   VÉRIFICATION DE LA DEUXIÈME PARTIES : LES MODULES
    # ---------------------------------------------------------------------
    path_data_modules = signup_folder + 'modules.msh'
    expect(path_data_modules).to be_exist
    success 'Le fichier des données de module existe'
    modules_ids = Marshal.load(path_data_modules.read)
    expect(modules_ids).to be_instance_of Array
    expect(modules_ids).to include 2
    expect(modules_ids).to include 4
    expect(modules_ids).to include 6

    # ---------------------------------------------------------------------
    #   Troisième partie de l'inscription : DOCUMENTS
    # ---------------------------------------------------------------------

    # Les fichiers de présentation
    fname_presentation  = 'Présentation de MDI.odt'
    fpresentation = File.expand_path(File.join('spec','asset','document',fname_presentation))
    fname_motivation    = 'Motivation de MDI.odt'
    fmotivation   = File.expand_path(File.join('spec','asset','document', fname_motivation))

    form_jid = 'form#form_documents'
    Benoit attache le fichier fpresentation,  a: 'signup_documents[presentation]', dans: form_jid
    Benoit attache le fichier fmotivation,    a: 'signup_documents[motivation]', dans: form_jid
    Benoit clique le bouton 'Enregistrer la candidature'

    # ---------------------------------------------------------------------
    #   VÉRIFICATION TROISIÈME ET DERNIÈRE PARTIE
    # ---------------------------------------------------------------------

    La feuille a pour titre 'Candidature Icare'
    La feuille a pour soustitre 'Confirmation de votre inscription'
    La feuille affiche 'votre candidature a bien été enregistrée'

    folder_documents = signup_folder + 'documents'
    expect(folder_documents).to be_exist
    success 'Le dossier temporaire des documents existe.'
    path_presentation = folder_documents + 'Document_presentation.odt'
    expect(path_presentation).to be_exist
    success 'Le fichier de présentation existe dans le dossier temporaire.'
    path_motivation   = folder_documents + 'Document_motivation.odt'
    expect(path_motivation).to be_exist
    success 'La lettre de motivation existe dans le dossier temporaire.'

    wdata = dbtable_watchers.get(where: "created_at > #{start_time} AND processus = 'valider_inscription'")
    user_id = wdata[:user_id]
    u = User.new(user_id)
    expect(u).not_to eq nil
    success "#{u.pseudo} est inscrit dans la base de données."

    expect(wdata[:processus]).to eq 'valider_inscription'
    expect(wdata[:objet]).to eq 'user'
    expect(wdata[:objet_id]).to eq user_id
    success 'Un watcher de validation de l’inscription existe, avec les bonnes données.'
    expect(wdata[:data]).to eq session_id
    success 'Le numéro de session est bien enregistré dans les `data` du watcher.'

    # =======================================================================
    # CONFIRMATION ET FIN DE L'INSCRIPTIOIN
    # ====================================================================
    dactu = {
      user_id:        user_id,
      message:        "Inscription de <strong>#{u.pseudo}</strong>.",
      created_after:  start_time
    }
    hactu = dbtable_actualites.get(where: "user_id = #{user_id} AND created_at > #{start_time}")
    expect(hactu).not_to eq nil
    expect(hactu[:message]).to eq "Inscription de <strong>#{u.pseudo}</strong>."
    success 'Une actualité annonçant l’inscription a été créée.'

    expect(u.options[2]).not_to eq '1'
    success "Les options indiquent que le mail n'est pas confirmé."

    u.recoit_le_mail(
      subject:      'Bienvenue !',
      message:      ["#{u.pseudo}, bienvenue à l'atelier Icare !"],
      sent_after:   start_time
    )

    u.recoit_le_mail(
      subject:      'Merci de confirmer votre mail',
      message:      ['Merci de bien vouloir confirmer votre adresse-mail'],
      sent_after:   start_time
    )

    data_mail = {
      sent_after:   start_time,
      subject:      'Nouvelle inscription',
      message:      ['Phil, je t\'informe d\'une nouvelle inscription', "#{u.pseudo}", "##{u.id}", "#{u.mail}"]
    }
    Phil recoit le mail data_mail

  end

  scenario 'Bureau administrateur après inscription' do
    test 'L’administrateur trouve les watchers de cette nouvelle inscription'

    # S'assurer qu'on ait au moins une inscription
    if dbtable_watchers.count(where: {processus: 'valider_inscription'}) == 0
      puts "Je dois simuler une inscription."
      sim = Simulate.new
      sim.inscription test: true
    end

    # On récupère la première inscription qu'on trouve
    hwatcher = dbtable_watchers.select(where:{processus: 'valider_inscription'}).last
    watcher_id  = hwatcher[:id]
    user_id     = hwatcher[:user_id]
    session_id  = hwatcher[:data]
    folder_signup = site.folder_tmp + "signup/#{session_id}"

    expect(folder_signup).to be_exist
    success 'Le dossier provisoire de l’inscription existe.'

    identify_phil
    La feuille a pour titre TITRE_BUREAU
    # sleep 60
    La feuille contient la liste 'watchers-user-1', class: 'notifications'
    form_jid = "form#form_watcher-#{hwatcher[:id]}"
    La feuille contient le formulaire "form_watcher-#{hwatcher[:id]}", dans: 'ul#watchers-user-1',
      success: 'Les notifications contienne le formulaire pour valider/refuser l’inscription'

    La feuille contient le link 'Download présentation', dans: form_jid,
      success: 'La page contient un lien pour télécharger les documents de présentation'
    La feuille contient le menu "module_choisi-#{watcher_id}", name: 'module_choisi',
      success: 'La notification contient un menu pour définir le module choisi.'

  end


end
