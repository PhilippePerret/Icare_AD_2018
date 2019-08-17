=begin

  Test de l'envoi des commentaires par l'administrateur

=end
feature "Envoi des commentaires par l'administrateur" do

  scenario 'Phil peut transmettre ses commentaires' do

    start_time = Time.now.to_i - 1

    test 'Phil transmet les deux documents commentaires d’une icarienne'

    # ========= SIMULATION POUR EN ARRIVER LÀ ============
    sim = Simulate.new
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt', file: 'mon travail.odt'      .in_folder_document, note: '12'},
      {affixe: 'Travail_1_etape_1', final_name: 'Travail_1_etape_1.odt', file: 'Travail 1 étape 1.odt'.in_folder_document, note: '17'}
    ]
    data_simulate = {
      module:           2,
      documents:        data_documents,
      test_only_first:  true,
      sexe:             'F'
    }
    sim.after_admin_download data_simulate
    # ===================================================

    # ==== RÉCUPÉRATION DES DONNÉES =============
    hwatchers1 = sim.watchers[-2]
    hwatchers2 = sim.watchers[-1]
    form_doc1_id  = "form_watcher-#{hwatchers1[:id]}"
    form_doc2_id  = "form_watcher-#{hwatchers2[:id]}"
    form_doc1_jid = "form##{form_doc1_id}"
    form_doc2_jid = "form##{form_doc2_id}"
    # Documents et étape
    icetape = sim.user.icetape
    docs_ids = icetape.documents.split(' ').collect{|did| did.to_i}
    # =============================================

    # === PRÉ-VÉRIFICATIONS ===
    docs_ids.each do |doc_id|
      hdoc = dbtable_icdocuments.get(doc_id)
      # La date d'envoi des commentaires N'est PAS définie
      expect(hdoc).to have_key :time_comments
      expect(hdoc[:time_comments]).to eq nil
      expect(hdoc[:options][8].to_i).to eq 0
      expect(hdoc[:options][13].to_i).to eq 0
    end
    success 'Les données des deux documents sont conformes.'
    # ==========================

    identify_phil

    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id
    La feuille contient le formulaire form_doc2_id
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc1_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le premier document'
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc2_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le second document'

    # === TEST ===
    comments1 = 'mon_travail_comsPhil.odt'      .in_folder_document
    comments2 = 'Travail_1_etape_1_comsPhil.odt'.in_folder_document
    Phil attache le fichier comments1, a: 'comments[file]', dans: form_doc1_jid
    Phil clique le bouton 'OK', dans: form_doc1_jid

    # --- Vérification intermédiaire ---
    expect(User.new(sim.user_id).icetape.status).not_to eq 4
    success 'Le status de l’étape ne passe pas à 4 après le dépôt du premier document seulement.'
    # -----------------------------------

    transmit_time = Time.now.to_i - 1

    Phil attache le fichier comments2, a: 'comments[file]', dans: form_doc2_jid
    Phil clique le bouton 'OK', dans: form_doc2_jid

    # ===========================

    # On attend le retour sur la page pour procéder aux
    # vérifications.
    La feuille a pour titre TITRE_BUREAU

    # Les hash de données des deux documents
    hdocs =
      docs_ids.collect do |doc_id|
        dbtable_icdocuments.get(doc_id)
      end

    u = User.new(sim.user_id)
    icetape = u.icetape

    # ======= VÉRIFICATIONS =========

    La feuille ne contient plus le formulaire form_doc1_id
    La feuille ne contient plus le formulaire form_doc2_id

    expect(icetape.status).to eq 4
    success 'L’étape est passée au statut 4'


    # Sur les documents
    # -----------------
    # Les documents ont été enregistrés dans un dossier temporaire
    folder_download = site.folder_tmp + "download/owner-#{sim.user_id}-upload_comments-#{sim.user.icmodule.id}-#{icetape.id}"
    expect(folder_download).to be_exist
    success 'Le dossier temporaire pour les commentaires existe.'

    data_documents.each do |data_doc|
      fcname = "#{data_doc[:affixe]}_comsPhil.odt"
      fcpath = folder_download + fcname
      expect(fcpath).to be_exist
      success "Le document `#{fcname}' a été déposé dans le dossier à télécharger."
    end
    success 'Les deux documents ont été enregistrés dans un dossier temporaire.'

    data_mail = {
      sent_after:   start_time,
      subject:      "Les commentaires sur votre document “mon_travail.odt” vous attendent"
    }
    sim.user recoit le mail data_mail
    data_mail.merge!(subject: 'Les commentaires sur votre document “Travail_1_etape_1.odt” vous attendent')
    sim.user recoit le mail data_mail

    hdocs.each do |hdoc|

      expect(hdoc[:options][8].to_i).to eq 1
      success 'Les options du icdocument ont été bien réglées (bit 9 à 1)'
      expect(hdoc[:time_comments]).to be > start_time
      success 'La date de commentaire est correctement définie dans les données du document.'
      wdata = {objet: 'ic_document', objet_id: hdoc[:id], processus: 'user_download_comments'}
      expect(sim.user).to have_watcher(wdata)
    end

    dactu = dbtable_actualites.select(where: "created_at > #{transmit_time} AND user_id = #{sim.user_id}").last
    expect(dactu).not_to eq nil
    expect(dactu[:message]).to include "Phil transmet ses commentaires à <strong>#{sim.user.pseudo}</strong>"
    success 'Une actualité annonce le dépôt de commentaires'

  end
  # /fin test envoi normal de deux documents commentaires sur 2 documents au total











  scenario 'Dépôt d’un seul commentaire' do

    start_time = Time.now.to_i - 1

    test 'Phil transmet un seul commentaires sur les 2 documents'

    # ========= SIMULATION POUR EN ARRIVER LÀ ============
    sim = Simulate.new
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt', file: 'mon travail.odt'      .in_folder_document, note: '12'},
      {affixe: 'Travail_1_etape_1', final_name: 'Travail_1_etape_1.odt', file: 'Travail 1 étape 1.odt'.in_folder_document, note: '17'}
    ]
    data_simulate = {
      module:           3,
      documents:        data_documents,
      test_only_first:  true,
      sexe:             'F'
    }
    sim.after_admin_download data_simulate
    # ===================================================

    # ==== RÉCUPÉRATION DES DONNÉES =============
    hwatchers1 = sim.watchers[-2]
    hwatchers2 = sim.watchers[-1]
    form_doc1_id  = "form_watcher-#{hwatchers1[:id]}"
    form_doc2_id  = "form_watcher-#{hwatchers2[:id]}"
    form_doc1_jid = "form##{form_doc1_id}"
    form_doc2_jid = "form##{form_doc2_id}"
    # Documents et étape
    icetape = sim.user.icetape
    docs_ids = icetape.documents.split(' ').collect{|did| did.to_i}
    # =============================================

    # === PRÉ-VÉRIFICATIONS ===
    docs_ids.each do |doc_id|
      hdoc = dbtable_icdocuments.get(doc_id)
      # La date d'envoi des commentaires N'est PAS définie
      expect(hdoc).to have_key :time_comments
      expect(hdoc[:time_comments]).to eq nil
      expect(hdoc[:options][8].to_i).to eq 0
      expect(hdoc[:options][13].to_i).to eq 0
    end
    success 'Les données des deux documents sont conformes.'
    # ==========================

    identify_phil

    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id
    La feuille contient le formulaire form_doc2_id
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc1_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le premier document'
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc2_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le second document'

    # === TEST ===
    # Pas de commentaire sur le premier document
    Phil coche la checkbox 'comments[none]', dans: form_doc1_jid
    Phil clique le bouton 'OK', dans: form_doc1_jid

    # --- Vérification intermédiaire ---
    expect(User.new(sim.user_id).icetape.status).not_to eq 4
    success 'Le status de l’étape ne passe pas à 4 après le dépôt du premier document seulement.'
    # -----------------------------------

    comments2 = 'Travail_1_etape_1_comsPhil.odt'.in_folder_document
    Phil attache le fichier comments2, a: 'comments[file]', dans: form_doc2_jid
    Phil clique le bouton 'OK', dans: form_doc2_jid

    # ===========================

    # On attend le retour sur la page pour procéder aux
    # vérifications.
    La feuille a pour titre TITRE_BUREAU

    # Les hash de données des deux documents
    hdocs =
      docs_ids.collect do |doc_id|
        dbtable_icdocuments.get(doc_id)
      end
    hdoc1 = hdocs.first
    hdoc2 = hdocs.last

    u = User.new(sim.user_id)
    icetape = u.icetape

    # ======= VÉRIFICATIONS =========

    La feuille ne contient plus le formulaire form_doc1_id
    La feuille ne contient plus le formulaire form_doc2_id

    # Sur les documents
    # -----------------
    # Les documents ont été enregistrés dans un dossier temporaire
    folder_download = site.folder_tmp + "download/owner-#{sim.user_id}-upload_comments-#{sim.user.icmodule.id}-#{icetape.id}"
    expect(folder_download).to be_exist
    success 'Le dossier temporaire pour les commentaires existe.'
    nombre_comments = Dir["#{folder_download}/*.*"].count
    expect(nombre_comments).to eq 1
    success 'Il y a un seul document commentaire dans le dossier temporaire.'

    fcname = "mon_travail_comsPhil.odt"
    fcpath = folder_download + fcname
    expect(fcpath).not_to be_exist
    success "Le document `#{fcname}', n’a pas été déposé dans le dossier à télécharger."

    fcname = "Travail_1_etape_1_comsPhil.odt"
    fcpath = folder_download + fcname
    expect(fcpath).to be_exist
    success "Le document `#{fcname}' a été déposé dans le dossier à télécharger."


    data_mail = {
      sent_after:   start_time,
      subject:      "Les commentaires sur votre document “Travail_1_etape_1.odt” vous attendent"
    }
    sim.user recoit le mail data_mail

    data_mail.merge!(subject: 'Les commentaires sur votre document “mon_travail.odt” vous attendent')
    sim.user ne recoit pas le mail data_mail

    expect(hdoc1[:options][8].to_i).to eq 0
    expect(hdoc1[:options][13].to_i).to eq 1
    success 'Les options du 1er icdocument sont bien réglées (9e bit laissé à 0 et 14e bit mis à 1 — fin de cycle du document commentaires)'
    expect(hdoc1[:time_comments]).to eq nil
    success 'La date de commentaire du 1er document n’est pas définie.'
    wdata = {objet: 'ic_document', objet_id: hdoc1[:id], processus: 'user_download_comments'}
    expect(sim.user).not_to have_watcher(wdata)
    success 'Le premier document (non commenté) n’a pas généré de watcher pour télécharger les commentaires.'

    expect(hdoc2[:options][8].to_i).to eq 1
    expect(hdoc2[:options][13].to_i).to eq 0
    success 'Les options du 2e icdocument ont été bien réglées (bit 9 à 1)'
    expect(hdoc2[:time_comments]).to be > start_time
    success 'La date de commentaire du 2e document est correctement définie dans les données du document.'
    wdata = {objet: 'ic_document', objet_id: hdoc2[:id], processus: 'user_download_comments'}
    expect(sim.user).to have_watcher(wdata)
    success 'Le second document (commenté) a généré un watcher pour downloader les commentaires.'

    expect(icetape.status).to eq 4
    success 'L’étape est passée au statut 4'

  end
  # /fin de test sur un document commentaire envoyé et un document non commenté













  scenario 'Je ne dépose qu’un seul commentaire en oubliant de cocher la case “pas de commentaire”' do
    start_time = Time.now.to_i - 1

    test 'Phil transmet un seul commentaires en oubliant de cocher la case “sans commentaires”'

    # ========= SIMULATION POUR EN ARRIVER LÀ ============
    sim = Simulate.new
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt', file: 'mon travail.odt'      .in_folder_document, note: '12'},
      {affixe: 'Travail_1_etape_1', final_name: 'Travail_1_etape_1.odt', file: 'Travail 1 étape 1.odt'.in_folder_document, note: '17'}
    ]
    data_simulate = {
      module:           1,
      documents:        data_documents,
      test_only_first:  true,
      sexe:             'H'
    }
    sim.after_admin_download data_simulate
    # ===================================================

    # ==== RÉCUPÉRATION DES DONNÉES =============
    hwatchers1 = sim.watchers[-2]
    hwatchers2 = sim.watchers[-1]
    form_doc1_id  = "form_watcher-#{hwatchers1[:id]}"
    form_doc2_id  = "form_watcher-#{hwatchers2[:id]}"
    form_doc1_jid = "form##{form_doc1_id}"
    form_doc2_jid = "form##{form_doc2_id}"
    # Documents et étape
    icetape = sim.user.icetape
    docs_ids = icetape.documents.split(' ').collect{|did| did.to_i}
    # =============================================

    # === PRÉ-VÉRIFICATIONS ===
    docs_ids.each do |doc_id|
      hdoc = dbtable_icdocuments.get(doc_id)
      # La date d'envoi des commentaires N'est PAS définie
      expect(hdoc).to have_key :time_comments
      expect(hdoc[:time_comments]).to eq nil
      expect(hdoc[:options][8].to_i).to eq 0
      expect(hdoc[:options][13].to_i).to eq 0
    end
    success 'Les données des deux documents sont conformes.'
    # ==========================

    identify_phil

    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_doc1_id
    La feuille contient le formulaire form_doc2_id
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc1_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le premier document'
    La feuille contient la balise 'input', type: 'checkbox', name: 'comments[none]', dans: form_doc2_jid,
      success: 'Le formulaire contient une CB pour dire aucun commentaire pour le second document'

    # === TEST AVEC ERREUR ===
    # Pas de commentaire sur le premier document
    # MAIS OUBLI DE COCHER LA CASE
    # # # # Phil coche la checkbox 'comments[none]', dans: form_doc1_jid
    Phil clique le bouton 'OK', dans: form_doc1_jid

    # --- Vérification intermédiaire ---
    expect(User.new(sim.user_id).icetape.status).not_to eq 4
    success 'Le status de l’étape ne passe pas à 4 après le dépôt du premier document seulement.'

    # === PREMIÈRE VÉRIFICATION ===
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message erreur 'Il faut fournir le document commentaire'
    La feuille affiche le message erreur 'ou cocher la case `Pas de commentaires`'
    La feuille contient encore le formulaire form_doc1_id
    hdoc = dbtable_icdocuments.get(docs_ids.first)
    expect(hdoc[:options][13].to_i).to eq 0
    success 'Les options du document n’ont pas été modifiées.'
    u = User.new(sim.user_id)
    expect(u.icetape.status).to eq 3
    sim.user ne recoit pas le mail(sent_after: start_time, subject: 'Les commentaires sur votre document')

    # Phil coche cette fois la case
    Phil coche la checkbox 'comments[none]', dans: form_doc1_jid
    Phil clique le bouton 'OK', dans: form_doc1_jid

    # Petite vérification après le premier document
    hdoc = dbtable_icdocuments.get(docs_ids.first)
    expect(hdoc[:options][13].to_i).to eq 1
    success 'Les options du document ont été modifiées (fin de cycle du commentaires, même s’il n’existe pas).'
    u = User.new(sim.user_id)
    expect(u.icetape.status).to eq 3
    success 'L’étape est toujours au statut 3'

    # -----------------------------------

    comments2 = 'Travail_1_etape_1_comsPhil.odt'.in_folder_document
    Phil attache le fichier comments2, a: 'comments[file]', dans: form_doc2_jid
    Phil clique le bouton 'OK', dans: form_doc2_jid

    # ===========================

    # On attend le retour sur la page pour procéder aux
    # vérifications.
    La feuille a pour titre TITRE_BUREAU

    # Les hash de données des deux documents
    hdocs =
      docs_ids.collect do |doc_id|
        dbtable_icdocuments.get(doc_id)
      end
    hdoc1 = hdocs.first
    hdoc2 = hdocs.last

    u = User.new(sim.user_id)
    icetape = u.icetape

    # ======= VÉRIFICATIONS =========

    La feuille ne contient plus le formulaire form_doc1_id
    La feuille ne contient plus le formulaire form_doc2_id

    # Sur les documents
    # -----------------
    # Les documents ont été enregistrés dans un dossier temporaire
    folder_download = site.folder_tmp + "download/owner-#{sim.user_id}-upload_comments-#{sim.user.icmodule.id}-#{icetape.id}"
    expect(folder_download).to be_exist
    success 'Le dossier temporaire pour les commentaires existe.'
    nombre_comments = Dir["#{folder_download}/*.*"].count
    expect(nombre_comments).to eq 1
    success 'Il y a un seul document commentaire dans le dossier temporaire.'

    fcname = "mon_travail_comsPhil.odt"
    fcpath = folder_download + fcname
    expect(fcpath).not_to be_exist
    success "Le document `#{fcname}', n’a pas été déposé dans le dossier à télécharger."

    fcname = "Travail_1_etape_1_comsPhil.odt"
    fcpath = folder_download + fcname
    expect(fcpath).to be_exist
    success "Le document `#{fcname}' a été déposé dans le dossier à télécharger."


    data_mail = {
      sent_after:   start_time,
      subject:      "Les commentaires sur votre document “Travail_1_etape_1.odt” vous attendent"
    }
    sim.user recoit le mail data_mail

    data_mail.merge!(subject: 'Les commentaires sur votre document “mon_travail.odt” vous attendent')
    sim.user ne recoit pas le mail data_mail

    expect(hdoc1[:options][8].to_i).to eq 0
    expect(hdoc1[:options][13].to_i).to eq 1
    success 'Les options du 1er icdocument sont bien réglées (9e bit laissé à 0 et 14e bit mis à 1 — fin de cycle du document commentaires)'
    expect(hdoc1[:time_comments]).to eq nil
    success 'La date de commentaire du 1er document n’est pas définie.'

    expect(hdoc2[:options][8].to_i).to eq 1
    expect(hdoc2[:options][13].to_i).to eq 0
    success 'Les options du 2e icdocument ont été bien réglées (bit 9 à 1)'
    expect(hdoc2[:time_comments]).to be > start_time
    success 'La date de commentaire du 2e document est correctement définie dans les données du document.'


    expect(icetape.status).to eq 4
    success 'L’étape est passée au statut 4'


  end

end
