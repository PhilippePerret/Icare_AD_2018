=begin

=end
feature "Télécharger des commentaires par l'icarien" do
  scenario "Un icarien récupère ses commentaires sur le site" do

    start_time = Time.now.to_i - 1

    test 'L’icarien récupère 2 documents commentaires sur trois originaux envoyés (1 non commenté)'

    # ========= SIMULATION POUR EN ARRIVER LÀ ============
    sim = Simulate.new
    # Les données des documents transmis
    data_documents = [
      {affixe: 'Travail_2_etape_1', final_name: 'Travail_2_etape_1.odt',  file: 'Travail 2 étape 1.odt'.in_folder_document, note: '15', comments: false},
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt',        file: 'mon travail.odt'      .in_folder_document, note: '12', comments: true},
      {affixe: 'Travail_1_etape_1', final_name: 'Travail_1_etape_1.odt',  file: 'Travail 1 étape 1.odt'.in_folder_document, note: '17', comments: true}
    ]
    upwd = 'coucouunmotdepasse'
    data_simulate = {
      password:         upwd,
      module:           3,
      documents:        data_documents,
      test_only_first:  true,
      sexe:             'F'
    }
    sim.after_upload_comments data_simulate
    # ===================================================

    # --- Quelques données et préparations ---
    zipped_doc1     = downloads_folder + 'mon_travail_comsPhil.zip'
    zipped_doc1.remove if zipped_doc1.exist?
    zipped_doc2     = downloads_folder + 'Travail_1_etape_1_comsPhil.zip'
    zipped_doc2.remove if zipped_doc2.exist?
    downloaded_doc1 = downloads_folder + 'mon_travail_comsPhil.odt'
    downloaded_doc1.remove if downloaded_doc1.exist?
    downloaded_doc2 = downloads_folder + 'Travail_1_etape_1_comsPhil.odt'
    downloaded_doc2.remove if downloaded_doc2.exist?
    # --------------------------------------------------------------------

    # ==== RÉCUPÉRATION DES DONNÉES =============
    pseudo = sim.user.pseudo
    hwatcher1 = sim.watchers[-2]
    hwatcher2 = sim.watchers[-1]
    form_doc1_id  = "form_watcher-#{hwatcher1[:id]}"
    form_doc2_id  = "form_watcher-#{hwatcher2[:id]}"
    form_doc1_jid = "form##{form_doc1_id}"
    form_doc2_jid = "form##{form_doc2_id}"
    doc1_id = hwatcher1[:objet_id]
    doc2_id = hwatcher2[:objet_id]
    # Documents et étape
    icetape = sim.user.icetape
    docs_ids = icetape.documents.split(' ').collect{|did| did.to_i}
    expect(docs_ids.count).to eq 3
    success 'Il y a bien 3 documents enregistrés dans la données de l’étape.'
    # Note : il y a 3 ids de document, le premier n'a pas été
    # commenté.
    # =============================================

    # === VÉRIFICATIONS PRÉLIMINAIRES ===
    expect(sim.user.icetape.status).to eq 4

    # ======================================

    # L'icarien s'identifie (et rejoint son bureau)
    identify mail: sim.user.mail, password: upwd

    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id
    La feuille contient le bouton 'Obtenir', dans: form_doc1_jid
    messbal = 'ci-dessous pour obtenir les commentaires émis sur votre document'
    La feuille contient la balise 'div', text: messbal, dans: form_doc1_jid
    La feuille contient le formulaire form_doc2_id
    La feuille contient le bouton 'Obtenir', dans: form_doc2_jid
    La feuille contient la balise 'div', text: messbal, dans: form_doc2_jid

    # === OPÉRATION TEST ===============
    sim.user clique sur le bouton 'Obtenir', dans: form_doc1_jid
    sleep 1

    # On doit trouver le document commentaire dans son dossier downloads
    expect(zipped_doc1).to be_exist
    success 'Le premier commentaire zippé a été downloadé'
    expect(zipped_doc2).not_to be_exist
    success 'Le second commentaire zippé N’a PAS été downloadé'

    expect(User.new(sim.user_id).icetape.status).to eq 4
    success 'Le status de l’étape est resté à 4'

    wdata = {objet: 'ic_document', objet_id: doc1_id, processus: 'depot_qdd'}
    expect(sim.user).to have_watcher(wdata)
    wdata.merge!(objet_id: doc2_id)
    success 'Un watcher créé pour déposer les PDF sur le QDD pour le premier commentaire (2e document)'
    hdoc1 = dbtable_icdocuments.get(doc1_id)
    expect(hdoc1[:options][10].to_i).to eq 1
    success 'Les options du document 1 ont été modifiées (11e bit à 1)'

    expect(sim.user).not_to have_watcher(wdata)
    success 'Aucun watcher pour le second commentaire (3e document)'

    mail_data = {sent_after: start_time, subject: 'Téléchargement de commentaires'}
    Phil ne recoit pas le mail mail_data

    # ========= SECONDE OPÉRATION TEST ==========
    sim.user clique sur le bouton 'Obtenir', dans: form_doc2_jid
    sleep 1

    # === TROISIÈME TEST : RE-CLICK ====
    # L'icarien peut cliquer encore une fois
    sim.user clique sur le bouton 'Obtenir', dans: form_doc2_jid
    sleep 1

    La feuille affiche le message erreur 'Vous demandez une action inconnue'

    # === VÉRIFICATION ===
    expect(zipped_doc2).to be_exist
    success 'Le second commentaire zippé a été downloadé'

    expect(User.new(sim.user_id).icetape.status).to eq 5
    success 'Le status de l’étape est passé à 5'

    hdoc2 = dbtable_icdocuments.get(doc2_id)
    expect(hdoc2[:options][10].to_i).to eq 1
    success 'Les options du 2nd document ont été modifiées (11e bit à 1)'

    wdata = {objet: 'ic_document', objet_id: doc2_id, processus: 'depot_qdd'}
    expect(sim.user).to have_watcher(wdata)
    success 'Un watcher créé pour déposer les PDF sur le QDD pour le second commentaire (3e document)'

    mail_data = {sent_after: start_time, subject: 'Téléchargement de commentaires'}
    Phil recoit le mail mail_data

    # Non, un message est impossible puisque la page n'est pas rechargée
    # La feuille affiche le message "Bonne lecture à vous, #{pseudo}"
  end
end
