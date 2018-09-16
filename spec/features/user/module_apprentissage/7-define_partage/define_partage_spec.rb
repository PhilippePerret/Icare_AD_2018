feature "Définition du partage des documents" do
  scenario "Une icarienne partage tous ses documents (3)" do

    start_time = Time.now.to_i - 1

    test 'Une icarienne partage ses 3 documents (dont 2 sont commentés)'

    # === SIMULATION POUR ARRIVER À L'ÉTAT VOULU ===
    # Les données des documents transmis
    data_documents = [
      {affixe: 'mon_travail',       final_name: 'mon_travail.odt',        file: 'mon travail.odt'      .in_folder_document, note: '12', comments: true},
      {affixe: 'Travail_1_etape_6', final_name: 'Travail_1_etape_6.odt',  file: 'Travail 1 étape 6.odt'.in_folder_document, note: '17', comments: true},
      {affixe: 'Travail_2_etape_6', final_name: 'Travail_2_etape_6.odt',  file: 'Travail 2 étape 6.odt'.in_folder_document, note: '15', comments: false}
    ]
    upwd = 'sonmotdepasse'
    data_simulate = {
      password:         upwd,
      module:           1,
      documents:        data_documents,
      test_only_first:  true,
      etape:            6,
      sexe:             'H'
    }
    sim = Simulate.new
    sim.after_depot_qdd data_simulate

    # RÉCUPÉRATION DES DONNÉES
    # --------------------------
    watcher_doc1  = sim.watchers[-3]
    watcher_doc1_id = watcher_doc1[:id]
    doc1_id       = watcher_doc1[:objet_id]
    form_doc1_id  = "form_watcher-#{watcher_doc1_id}"
    form_doc1_jid = "form##{form_doc1_id}"

    watcher_doc2  = sim.watchers[-2]
    watcher_doc2_id = watcher_doc2[:id]
    doc2_id       = watcher_doc2[:objet_id]
    form_doc2_id  = "form_watcher-#{watcher_doc2[:id]}"
    form_doc2_jid = "form##{form_doc2_id}"

    watcher_doc3  = sim.watchers[-1]
    watcher_doc3_id = watcher_doc3[:id]
    doc3_id       = watcher_doc3[:objet_id]
    form_doc3_id  = "form_watcher-#{watcher_doc3[:id]}"
    form_doc3_jid = "form##{form_doc3_id}"

    li_doc1_id = "li_watcher-#{watcher_doc1[:id]}"
    li_doc1_jid = "li##{li_doc1_id}"
    li_doc2_id = "li_watcher-#{watcher_doc2[:id]}"
    li_doc2_jid = "li##{li_doc2_id}"
    li_doc3_id = "li_watcher-#{watcher_doc3[:id]}"
    li_doc3_jid = "li##{li_doc3_id}"

    # Liste des identifiants des trois documents
    docs_ids = [doc1_id, doc2_id, doc3_id]

    icdoc1 = IcModule::IcEtape::IcDocument.new(doc1_id)
    icetape = icdoc1.icetape

    # =====================================================

    # === VÉRIFICATIONS PRÉLIMINAIRES ===
    # les watchers define_partage n'existe plus
    dreq = {user_id: sim.user_id, processus: 'define_partage'}
    expect(dbtable_watchers.count(where: dreq)).to eq 3
    expect(User.new(sim.user_id).icetape.status).to eq 6


    # === TEST ===
    # L'icarienne rejoint le site pour partager ses documents (ou non)
    identify password: upwd, mail: sim.user.mail

    La feuille a pour titre TITRE_BUREAU
    # === VÉRIFICATIONS PRÉ-TEST ===
    # La page contient bien les notifications pour définir le
    # partage de chaque document
    La feuille contient le formulaire form_doc1_id
    La feuille contient la balise 'legend', text: 'Définition de partage', dans: li_doc1_jid
    La feuille contient la balise 'pre', text: data_documents[0][:final_name], dans: form_doc1_jid
    La feuille contient le menu "sharing_original-#{doc1_id}", dans: form_doc1_jid
    La feuille contient le menu "sharing_comments-#{doc1_id}", dans: form_doc1_jid
    La feuille contient le formulaire form_doc2_id
    La feuille contient le menu "sharing_original-#{doc2_id}", dans: form_doc2_jid
    La feuille contient le menu "sharing_comments-#{doc2_id}", dans: form_doc2_jid
    La feuille contient le formulaire form_doc3_id
    La feuille contient le menu "sharing_original-#{doc3_id}", dans: form_doc3_jid
    La feuille ne contient pas le menu "sharing_comments-#{doc3_id}", dans: form_doc3_jid


    # === TEST ===
    # L'icarien définit le partage de son premier document
    sim.user choisit le menu 'Partager', dans: "#{form_doc1_jid} select[name=\"sharing[original]\"]"
    sim.user choisit le menu 'Partager', dans: "#{form_doc1_jid} select[name=\"sharing[comments]\"]"
    sim.user clique le bouton 'Définir', dans: form_doc1_jid
    La feuille a pour titre TITRE_BUREAU

    # === VÉRIFICATION APRÈS SEULEMENT LE PREMIER DÉFINI ===
    La feuille affiche le message "Merci pour la définition du partage de “#{data_documents.first[:final_name]}”"
    data_mail = {sent_after: start_time, subject: 'Définition du partage de documents'}
    Phil ne recoit pas le mail data_mail
    expect(User.new(sim.user_id).icetape.status).not_to eq 7
    success 'L’étape n’est pas encore passée au statut 7'

    # === DÉFINITION DU PARTAGE DES DEUX AUTRES ===
    sim.user choisit le menu 'Partager', dans: "#{form_doc2_jid} select[name=\"sharing[original]\"]"
    sim.user choisit le menu 'Ne pas partager', dans: "#{form_doc2_jid} select[name=\"sharing[comments]\"]"
    sim.user clique le bouton 'Définir', dans: form_doc2_jid
    La feuille a pour titre TITRE_BUREAU

    # === DÉFINITION DU PARTAGE DU TROISIÈME ===
    sim.user choisit le menu 'Ne pas partager', dans: "#{form_doc3_jid} select[name=\"sharing[original]\"]"
    sim.user clique le bouton 'Définir', dans: form_doc3_jid
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message "Merci d'avoir défini le partage de tous vos documents de l'étape #{icetape.abs_etape.numero}"

    # === VÉRIFICATIONS ===
    # les watchers define_partage n'existe plus
    dreq = {user_id: sim.user_id, processus: 'define_partage'}
    expect(dbtable_watchers.count(where: dreq)).to eq 0
    # Les formulaires ne sont plus affichés
    La feuille ne contient plus le formulaire form_doc1_id
    La feuille ne contient plus le formulaire form_doc2_id
    La feuille ne contient plus le formulaire form_doc3_id

    docs_ids.each_with_index do |doc_id, index_doc|
      icdoc = IcModule::IcEtape::IcDocument.new(doc_id)
      expect(icdoc.options[5].to_i).to eq 1
      expect(icdoc.options[13].to_i).to eq 1
      # Pour ce test :
      #   le premier document a été entièrement partagé
      #   le deuxième document est partagé au niveau de son original
      #   le troisième ne partage pas son original (2) et ne possède
      #   pas de commentaires (3)
      ori_sharing, com_sharing =
        case index_doc
        when 0 then [1,1]
        when 1 then [1,2]
        when 2 then [2,3]
        end
      expect(icdoc.options[1].to_i).to eq ori_sharing
      expect(icdoc.options[9].to_i).to eq com_sharing
    end
    success 'Le cycle de tous les documents a été terminé et le partage a été correctement défini.'

    expect(User.new(sim.user_id).icetape.status).to eq 7
    success 'L’étape est passée au statut 7'

    # Une actualité a été produite
    # On prend la toute dernière actualité
    actu = dbtable_actualites.select(where: "user_id = #{sim.user_id} AND created_at > #{start_time}").last
    expect(actu).not_to eq nil
    expect(actu[:message]).to include "définit le partage de ses documents"

    data_mail = {
      sent_after: start_time,
      subject: 'Définition du partage de documents',
      message: ['Original <span class="green">partagé</span>', 'Original <span class="red">non partagé</span>', 'Commentaires <span class="green">partagés</span>', 'Commentaires <span class="red">non partagés</span>', "Commentaires inexistants"]
    }
    Phil recoit le mail data_mail
  end
end
