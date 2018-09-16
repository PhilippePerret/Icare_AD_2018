=begin

  Dans ce test, je dépose les documents PDF sur le quai des docs

=end
feature "Dépot des documents sur le quai des docs" do
  before(:all) do
    protect_qdd_pdfs
  end
  after(:all) do
    unprotect_qdd_pdfs
  end
  scenario 'Je dépose les documents sur le quai des docs' do
    test 'Dépôt de 3 documents sur le QDD dont 2 ont été commentés'

    start_time = Time.now.to_i - 1

    # ========= SIMULATION POUR EN ARRIVER LÀ ============
    sim = Simulate.new
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt',        file: 'mon travail.odt'      .in_folder_document, note: '12', comments: true},
      {affixe: 'Travail_1_etape_10', final_name: 'Travail_1_etape_10.odt',  file: 'Travail 1 étape 10.odt'.in_folder_document, note: '17', comments: true},
      {affixe: 'Travail_2_etape_10', final_name: 'Travail_2_etape_10.odt',  file: 'Travail 2 étape 10.odt'.in_folder_document, note: '15', comments: false}
    ]
    data_simulate = {
      module:           4,
      documents:        data_documents,
      test_only_first:  true,
      etape:            10,
      sexe:             'F'
    }
    sim.after_user_download_comments data_simulate
    # ===================================================

    # === DONNÉES UTILES ===
    watcher_doc1  = sim.watchers[-3]
    watcher_doc1_id = watcher_doc1[:id]
    doc1_id       = watcher_doc1[:objet_id]
    form_doc1_id  = "form_watcher-#{watcher_doc1_id}"
    form_doc1_jid = "form##{form_doc1_id}"
    # Path du document dans le dossier PDFs
    # Format du nom, pour mémoire :
    # "<short name module capitalisé>_etape_<numéro étape>_<pseudo auteur>_<id document>_(original|comments).pdf"
    qdd_doc1_ori_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc1_id}_original.pdf"
    qdd_doc1_ori_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc1_ori_name}"
    qdd_doc1_com_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc1_id}_comments.pdf"
    qdd_doc1_com_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc1_com_name}"

    watcher_doc2  = sim.watchers[-2]
    watcher_doc2_id = watcher_doc2[:id]
    doc2_id       = watcher_doc2[:objet_id]
    form_doc2_id  = "form_watcher-#{watcher_doc2[:id]}"
    form_doc2_jid = "form##{form_doc2_id}"
    # Path du document dans le dossier PDFs
    qdd_doc2_ori_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc2_id}_original.pdf"
    qdd_doc2_ori_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc2_ori_name}"
    qdd_doc2_com_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc2_id}_comments.pdf"
    qdd_doc2_com_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc2_com_name}"

    watcher_doc3  = sim.watchers[-1]
    watcher_doc3_id = watcher_doc3[:id]
    doc3_id       = watcher_doc3[:objet_id]
    form_doc3_id  = "form_watcher-#{watcher_doc3[:id]}"
    form_doc3_jid = "form##{form_doc3_id}"
    # Path du document dans le dossier PDFs
    qdd_doc3_ori_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc3_id}_original.pdf"
    qdd_doc3_ori_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc3_ori_name}"
    # Le document suivant ne doit jamais exister
    qdd_doc3_com_name = "Personnage_etape_1_#{sim.user.pseudo}_#{doc3_id}_comments.pdf"
    qdd_doc3_com_path = site.folder_data + "qdd/pdfs/4/#{qdd_doc3_com_name}"

    # === PRÉ-VÉRIFICATIONS ===
    wdata = {where: {objet: 'ic_document', objet_id: doc1_id, processus: 'define_partage'}}
    expect(dbtable_watchers.count(wdata)).to eq 0
    wdata[:where].merge!(objet_id: doc2_id)
    expect(dbtable_watchers.count(wdata)).to eq 0
    wdata[:where].merge!(objet_id: doc3_id)
    expect(dbtable_watchers.count(wdata)).to eq 0
    success 'Il n’y a aucun watcher pour définir le partage pour les 3 documents'

    # === TEST ===
    identify_phil
    # On attend d'être sur le bureau

    # === VÉRIFICATIONS DU BUREAU ===
    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id
    La feuille contient la balise 'input', type: 'file', name: 'document[original]', id: "document_original-#{doc1_id}", dans: form_doc1_jid,
      success: 'La page contient le champ pour déposer le document original du premier document.'
    La feuille contient la balise 'input', type: 'file', name: 'document[comments]', id: "document_comments-#{doc1_id}", dans: form_doc1_jid,
      success: 'La page contient le champ pour déposer le document commentaire du premier document.'
    La feuille contient le formulaire form_doc2_id
    La feuille contient la balise 'input', type: 'file', name: 'document[original]', id: "document_original-#{doc2_id}", dans: form_doc2_jid,
      success: 'La page contient le champ pour déposer le document original du deuxième document.'
    La feuille contient la balise 'input', type: 'file', name: 'document[comments]', id: "document_comments-#{doc2_id}", dans: form_doc2_jid,
      success: 'La page contient le champ pour déposer le document commentaire du deuxième document.'
    La feuille contient le formulaire form_doc3_id
    La feuille contient la balise 'input', type: 'file', name: 'document[original]', id: "document_original-#{doc3_id}", dans: form_doc3_jid,
      success: 'La page contient le champ pour déposer le document original du troisième document.'
    La feuille ne contient pas la balise 'input', type: 'file', name: 'document[comments]', id: "document_comments-#{doc3_id}", dans: form_doc3_jid,
      success: 'La page NE contient PAS le champ pour déposer le document commentaire du troisième document, car il n’en a pas.'

    # === PRÉPARATION DES DOCUMENTS ===
    # On doit préparer 5 documents PDFs à déposer (note : il faut toujours déposer
    # tous les documents, on ne doit jamais en oublier)
    pdf_ori_doc1 = 'mon_travail.pdf'                  .in_folder_document
    pdf_com_doc1 = 'mon_travail_comsPhil.pdf'         .in_folder_document
    pdf_ori_doc2 = 'Travail_1_etape_10.pdf'           .in_folder_document
    pdf_com_doc2 = 'Travail_1_etape_10_comsPhil.pdf'  .in_folder_document
    pdf_ori_doc3 = 'Travail_2_etape_10.pdf'           .in_folder_document

    # === OPÉRATION TEST ===
    Phil attache le document pdf_ori_doc1.to_s, a: "document_original-#{doc1_id}", dans: form_doc1_jid
    Phil attache le document pdf_com_doc1.to_s, a: "document_comments-#{doc1_id}", dans: form_doc1_jid
    Phil clique sur le bouton 'Déposer', dans: form_doc1_jid

    # === PREMIÈRES VÉRIFICATIONS ===
    La feuille a pour titre TITRE_BUREAU

    expect(qdd_doc1_ori_path).to be_exist
    success 'Le document original du 1er document existe sur le Quai des docs'
    expect(qdd_doc1_com_path).to be_exist
    success 'Le document commentaire du 1er document existe sur le Quai des docs'
    expect(dbtable_watchers.get(watcher_doc1_id)).to eq nil
    success 'Le watcher pour déposer le 1er document sur le Quai des docs a été supprimé'
    expect(dbtable_watchers.get(watcher_doc2_id)).not_to eq nil
    expect(dbtable_watchers.get(watcher_doc3_id)).not_to eq nil
    success 'Mais les deux autres watchers existent toujours.'
    wdata = {objet: 'ic_document', objet_id: doc1_id, processus: 'define_partage'}
    expect(dbtable_watchers.count(where: wdata)).to eq 1
    success 'Un watcher a été créé pour définir le partage du 1er document.'
    statut_etape = User.new(sim.user_id).icetape.status
    expect(statut_etape).not_to eq 6
    expect(statut_etape).to eq 5
    icdoc = IcModule::IcEtape::IcDocument.new(doc1_id)
    expect(icdoc.options[3].to_i).to eq 1
    expect(icdoc.options[11].to_i).to eq 1
    success 'Les options (3e et 11e bit) du document ont été réglées à 1'
    expect(icdoc.cote_original).to eq nil
    success 'La cote de l’original a été mis à nil'
    data_mail = {sent_after: start_time, subject: 'Définition du partage de documents'}
    sim.user ne recoit pas le mail data_mail

    # === TEST : DEUXIÈME ÉTAPE ===

    Phil attache le document pdf_ori_doc2, a: "document_original-#{doc2_id}", dans: form_doc2_jid
    Phil attache le document pdf_com_doc2, a: "document_comments-#{doc2_id}", dans: form_doc2_jid
    Phil clique sur le bouton 'Déposer', dans: form_doc2_jid

    # === DEUXIÈMES VÉRIFICATIONS ===

    expect(qdd_doc2_ori_path).to be_exist
    success 'Le document original du 2e document existe sur le Quai des docs'
    expect(qdd_doc2_com_path).to be_exist
    success 'Le document commentaire du 2e document existe sur le Quai des docs'
    icdoc = IcModule::IcEtape::IcDocument.new(doc2_id)
    expect(icdoc.options[3].to_i).to eq 1
    expect(icdoc.options[11].to_i).to eq 1
    expect(icdoc.cote_original).to eq nil
    success 'La cote de l’original du 2e document a été mis à nil'
    success 'Les options (3e et 11e bit) du 2e document ont été réglées à 1'
    data_mail = {sent_after: start_time, subject: 'Définition du partage de documents'}
    sim.user ne recoit pas le mail data_mail

    # === TEST : TROISIÈME ÉTAPE, LE DERNIER DOCUMENT ===
    # Erreur volontaire : on ne soumet aucun document
    # Phil attache le document pdf_ori_doc3, a: "document_original-#{doc3_id}", dans: form_doc3_jid
    Phil clique sur le bouton 'Déposer', dans: form_doc3_jid
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message erreur 'Il faut absolument fournir le document'
    icdoc = IcModule::IcEtape::IcDocument.new(doc3_id)
    expect(icdoc.options[3].to_i).to eq 0
    success 'Les bits d’options n’ont pas été modifiées pour le document.'

    # === TEST : QUATRIÈME ÉTAPE, LE DERNIER DOCUMENT ===
    Phil attache le document pdf_ori_doc3, a: "document_original-#{doc3_id}", dans: form_doc3_jid
    Phil clique sur le bouton 'Déposer', dans: form_doc3_jid



    # === QUATRIÈMES VÉRIFICATIONS ===
    expect(qdd_doc3_ori_path).to be_exist
    success 'Le document original du 3e document existe sur le Quai des docs'
    expect(qdd_doc3_com_path).not_to be_exist
    success 'Le document commentaire du 3e document n’existe pas'
    icdoc = IcModule::IcEtape::IcDocument.new(doc3_id)
    expect(icdoc.options[3].to_i).to eq 1
    expect(icdoc.options[11].to_i).to eq 0
    success 'Les options (3e bit seulement) du 3e document ont été réglées à 1 et 0'
    expect(icdoc.cote_original).to eq nil
    success 'La cote de l’original du 3e document a été mis à nil'

    # Changement de statut de l'étape
    expect(User.new(sim.user_id).icetape.status).to eq 6
    data_mail = {sent_after: start_time, subject: 'Définition du partage de documents'}
    sim.user recoit le mail data_mail

  end
end
