=begin

  Test du téléchargement des documents de travail par l'administrateur.

=end
feature "Téléchargement des documents de travail par l'administrateur" do
  scenario 'Un administrateur peut télécharger les documents de travail' do

    test 'Un administrateur peut télécharger les documents de travail'

    # =================== SIMULATION ================================
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt', file: 'mon travail.odt'      .in_folder_document, note: '12'},
      {affixe: 'Travail_1_etape_1', final_name: 'Travail_1_etape_1.odt', file: 'Travail 1 étape 1.odt'.in_folder_document, note: '17'}
    ]
    sim = Simulate.new
    sim.after_send_work(
      module:           1,
      documents:        data_documents,
      test_only_first:  true
      )

    # Récupération des watchers
    watcher_doc1 = sim.watchers[-2]
    watcher_doc2 = sim.watchers[-1]
    li_doc1_id  = "li_watcher-#{watcher_doc1[:id]}"
    li_doc1_jid = "li##{li_doc1_id}"
    li_doc2_id  = "li_watcher-#{watcher_doc2[:id]}"
    li_doc2_jid = "li##{li_doc2_id}"
    expect(watcher_doc1[:objet]).to eq 'ic_document'
    expect(watcher_doc2[:objet]).to eq 'ic_document'
    doc1_id       = watcher_doc1[:objet_id]
    doc2_id       = watcher_doc2[:objet_id]
    hdoc1         = dbtable_icdocuments.get(doc1_id)
    hdoc2         = dbtable_icdocuments.get(doc2_id)
    hdocs = [hdoc1, hdoc2]
    form_doc1_id  = "form_watcher-#{watcher_doc1[:id]}"
    form_doc2_id  = "form_watcher-#{watcher_doc2[:id]}"
    form_doc1_jid = "form##{form_doc1_id}"
    form_doc2_jid = "form##{form_doc2_id}"
    # ===============================================================

    # === PRÉ-VÉRIFICATIONS ===
    dwatcher = {objet: 'ic_document', processus: 'admin_download', objet_id: doc1_id}
    expect(sim.user).to have_watcher dwatcher
    dwatcher.merge!(objet_id: doc2_id)
    expect(sim.user).to have_watcher dwatcher
    success 'Deux wachers existent bien pour downloader les documents'

    icetape = sim.user.icetape
    expect(icetape.status).to eq 2
    success 'Le statut de l’étape est 2 au départ'

    hdocs.each do |hdoc|
      expect(hdoc[:options][2].to_i).to eq 0
    end
    success 'Le 3e bit des options est à 0 pour les deux documents'


    # === TEST ===
    identify_phil
# sleep 60
    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id,
      success: 'La page contient le formulaire pour downloader le premier document.'
    La feuille contient le formulaire form_doc2_id,
      success: 'La page contient le formulaire pour downloader le second document.'
    La feuille contient la balise 'legend', text: "Download #{hdoc1[:original_name]}", dans: li_doc1_jid
    La feuille contient le bouton 'Télécharger', dans: form_doc1_jid
    La feuille contient le bouton 'Télécharger', dans: form_doc1_jid
    La feuille contient la balise 'legend', text: "Download #{hdoc2[:original_name]}", dans: li_doc2_jid

    # Avant de télécharger, il faut s'assurer que les fichiers n'existent pas
    # déjà dans le dossier de téléchargement (dans un test précédent)
    data_documents.each do |hdoc|
      final_sfile = downloads_folder + hdoc[:final_name]
      zip_sfile   = downloads_folder + "#{hdoc[:affixe]}.zip"
      final_sfile.remove  if final_sfile.exist?
      zip_sfile.remove    if zip_sfile.exist?
      !final_sfile.exist? || (raise "Le fichier #{final_sfile} ne devrait plus exister")
      !zip_sfile.exist?   || (raise "Le fichier #{zip_sfile} ne devrait plus exister")
    end

    Phil clique sur le bouton 'Télécharger', dans: form_doc1_jid
    sleep 0.5
    expect(User.new(sim.user_id).icetape.status).not_to eq 3
    success 'Le statut de l’icétape n’est pas encore passé à 3'
    Phil clique sur le bouton 'Télécharger', dans: form_doc2_jid
    sleep 0.5

    # === VÉRIFICATIONS ===
    # On prend les nouvelles données des deux documents

    hdoc1         = dbtable_icdocuments.get(doc1_id)
    hdoc2         = dbtable_icdocuments.get(doc2_id)
    hdocs = [hdoc1, hdoc2]



    data_documents.each do |hdoc|
      zip_path    = downloads_folder + "#{hdoc[:affixe]}.zip"
      final_sfile = downloads_folder + hdoc[:final_name]
      !final_sfile.exist? || final_sfile.remove
      Phil telecharge le fichier "#{hdoc[:affixe]}.zip"
      Phil dezippe le fichier "#{zip_path}", final_name: hdoc[:final_name]
    end

    u = User.new(sim.user_id)
    icetape = u.icetape

    expect(icetape.status).to eq 3
    success 'Le statut de l’étape est passé à 3'

    hwatchers = dbtable_watchers.select(where: {user_id: u.id, processus: 'upload_comments'})
    expect(hwatchers.count).to eq 2
    expect([doc1_id, doc2_id]).to include(hwatchers[0][:objet_id])
    expect([doc1_id, doc2_id]).to include(hwatchers[1][:objet_id])
    success 'Un watcher par document (donc 2) a été créé pour permettre d’updloader les commentaires.'

    hdocs.each do |hdoc|
      expect(hdoc[:options][2].to_i).to eq 1
    end
    success 'Le 3e bit des options a été mis à 1 (original téléchargé)'
  end
end
