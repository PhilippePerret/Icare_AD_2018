=begin

  Test de l'envoi de document de travail pour une étape
  -----------------------------------------------------
  C'est une opération particulièrement complexe dans le cas où il peut
  y avoir de nombreux cas qui se présentent.

=end
feature "Envoi de document de travail" do

  scenario "Une icarienne transmet avec succès un document de travail" do

    test 'Une icarienne transmet avec succès un document de travail'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    upwd =    'motdepasse'
    sim = Simulate.new
    sim.after_start_module(password: upwd, module: 2, test: true, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 2
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    dwatcher = {objet: 'ic_module', objet_id: sim.user.icmodule.id, processus: 'change_etape'}
    expect(sim.user).not_to have_watcher dwatcher
    success 'Aucun watcher n’existe pour passer le module à une autre étape.'


    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd
    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire form_id
    La feuille contient le link '+', dans: "#{form_jid} div.buttons",
      success: 'Un bouton “+” permet d’afficher un premier champ de saisie'

    sim.user clique le link '+', dans: "#{form_jid} div.buttons"
    La feuille contient la balise 'input', name: 'work[document1][file]', dans: form_jid
    La feuille contient la balise 'select', name: 'work[document1][estimation]', dans: form_jid

    # Procéder à l'envoi du document de travail
    document1 = 'Travail 1 étape 1.odt'.in_folder_document
    expect(File).to be_exist(document1)

    sim.user attache le fichier document1, a: 'work[document1][file]', dans: form_jid
    sim.user selectionne '7/20', dans: "#{form_jid} select#work_document1_estimation"
    shot 'bureau-avant-envoi-travail'
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid
    success "#{pseudo} a transmis le document, définit la note d'estimation et cliqué sur “Envoyer”"
    # === FIN TEST ===

    # ==== VÉRFIFICATION ===

    # === VÉRIFICATION DU BUREAU APRÈS REMISE ===
    # sleep 20
    La feuille a pour titre TITRE_BUREAU
    shot 'bureau-apres-envoi-travail'
    La feuille affiche le message "Merci #{pseudo}, votre document a été enregistré et transmis."
    La feuille ne contient plus le formulaire form_id,
      success: 'La page ne contient plus la notification pour l’envoi des documents.'

    wid_download_admin = dbtable_watchers.get(where: {user_id: sim.user_id, processus: 'admin_download'}, colonnes:[])[:id]
    txt = "Votre document “Travail_1_etape_1.odt” (étape 1 du module “Documents”) doit être téléchargé par Phil."
    La feuille contient la balise 'p', text: txt, dans: "li#li_watcher-#{wid_download_admin}",
      success: 'Une notification annonce le téléchargement prochain du document.'

    expect(dbtable_watchers.count(where:{id: hwtravail[:id]})).to eq 0
    success 'Le watcher pour envoyer le travail a été détruit.'

    hdocuments = dbtable_icdocuments.select(where: "user_id = #{sim.user_id} AND created_at > #{start_time}")
    expect(hdocuments.count).to eq 1
    success 'Le document a été créé dans la base de données'
    hdocument = hdocuments.first
    # puts "hdocument : #{hdocument.inspect}"
    icdoc_id = hdocument[:id]

    La feuille ne contient pas la balise 'li', id: "li_doc_qdd-#{icdoc_id}",
      success: 'Le document n’est pas affiché dans le Quai des docs de la page'

    # Cet enregistrement possède la bonne valeur @options
    doc_options = hdocument[:options]
    expect(doc_options).to eq '1'
    success 'Le document a la bonne valeur @options dans la table'

    expected_time = hdocument[:expected_comments]
    expect(expected_time).to be >= start_time + 6.days
    expect(expected_time).to be < start_time + 6.days + 100
    success 'Le document possède la bonne date de remise des commentaires.'

    expect(hdocument[:cote_original]).to eq 0.7
    success 'Le document possède la bonne note estimative'

    folderpath = site.folder_tmp + "download/owner-#{sim.user_id}-send_work-etape-1"
    # puts "Folder: #{folderpath}"
    expect(folderpath).to be_exist
    success 'Le dossier à télécharger existe'

    filepath = folderpath + hdocument[:original_name]
    # puts "Filepath: #{filepath}"
    expect(filepath).to be_exist
    success 'Le dossier du document existe dans le dossier'

    dwatcher = {objet: 'ic_document', objet_id: icdoc_id, processus: 'admin_download'}
    expect(sim.user).to have_watcher dwatcher
    success 'Un watcher a été créé pour télécharger le document.'

    dwatcher = {objet: 'ic_module', objet_id: sim.user.icmodule.id, processus: 'change_etape'}
    expect(sim.user).to have_watcher dwatcher
    success 'Un watcher a été créé pour passer l’icarienne à une autre étape.'

    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.status).to eq 2
    success 'L’étape est passé au statut 2'

    message = "<strong>#{pseudo}</strong> envoie son travail pour l’étape 1 du module “Documents”."
    drequest = "created_at > #{start_time} AND user_id = #{sim.user_id} AND message = \"#{message}\""
    expect(dbtable_actualites.count(drequest)).to eq 1
    success 'Une actualité annonce l’envoi des documents.'

    expect(icetape.documents).to eq "#{icdoc_id}"
    success 'La donnée @documents de l’étape consigne bien le document.'

    dmail = {
      sent_after: start_time,
      subject:  'Envoi de travail pour une étape',
      message:  ["<strong>#{pseudo}</strong> vient de déposer des documents de travail.", "Docs-ids  : #{icdoc_id}"]
    }
    Phil recoit le mail dmail,
      success: 'Phil reçoit un mail pour télécharger les documents.'

    puts "Mail : #{sim.user.mail} / #{upwd}"
  end








  scenario 'Une icarienne envoie un document en oubliant la note' do

    test 'Une icarienne envoie un document en oubliant la note'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    upwd =    'motdepasse'
    sim = Simulate.new
    sim.after_start_module(password: upwd, module: 2, test: false, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 2
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd

    document1 = 'Travail 1 étape 1.odt'.in_folder_document

    sim.user clique le link '+', dans: form_jid
    sim.user attache le document document1, a: 'work[document1][file]', dans: form_jid
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===

    postu = User.new(sim.user_id)

    La feuille a pour titre TITRE_BUREAU
    mess_err = "Merci d’attribuer une note estimative à vos documents"
    La feuille affiche le message erreur mess_err
    expect(dbtable_watchers.count(where:{id: hwtravail[:id]})).to eq 1
    success 'Le watcher d’envoi existe toujours dans la base.'
    La feuille contient le formulaire form_id
    success 'Le watcher d’envoi existe toujours sur la page.'
    datamail = {sent_after: start_time, subject: 'Envoi de travail pour une étape'}
    Phil ne recoit pas le mail datamail
    hdocs = dbtable_icdocuments.select(where:{user_id: sim.user_id})
    expect(hdocs.count).to eq 1
    hdoc = hdocs.first
    expect(hdoc[:cote_original]).to eq nil
    success 'La donnée document a été enregistrée mais aucune note n’a été affectée.'

    expect(postu.icetape.status).to eq 1
    success 'Le statut de l’étape est toujours 1'

    # Et maintenant elle fournit la note
    sim.user choisit '15/20', dans: "#{form_jid} select#work_document1_estimation"
    sleep 1
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===
    La feuille a pour titre TITRE_BUREAU
    postu = User.new(sim.user_id)
    expect(dbtable_watchers.count(where:{id: hwtravail[:id]})).to eq 0
    success 'Le watcher d’envoi de travail a été supprimé.'

    hdocs = dbtable_icdocuments.select(where:{user_id: sim.user_id})
    expect(hdocs.count).to eq 1
    hdoc = hdocs.first
    expect(hdoc[:cote_original]).to eq 1.5
    success 'Aucune autre donnée document n’a été enregistrée mais la note a été consignée.'

    wdata = {processus: 'admin_download', objet: 'ic_document'}
    expect(sim.user).to have_watcher(wdata)
    success 'Un watcher pour charger les documents a été créé'
    expect(postu.icetape.status).to eq 2
    success 'Le statut de l’étape est passé à 2'
    datamail = {sent_after: start_time, subject: 'Envoi de travail pour une étape'}
    Phil recoit le mail datamail,
      success: "Phil reçoit le mail l'invitant à télécharger les documents."
  end











  scenario 'Une icarienne envoie un document avec un nom trop long' do

    test 'Une icarienne envoie un document avec un nom trop long (par le deuxième champ)'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    upwd =    'motdepasse'
    sim = Simulate.new
    sim.after_start_module(password: upwd, module: 2, test: false, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 2
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd

    ndoc = 'Ceci est un document avec un nom vraiment trop long qui doit être raccourci sinon il dépasserait les limites de lautorisation actuelle.doc'
    document1 = ndoc.in_folder_document
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user choisit '10/20', dans: "#{form_jid} select#work_document2_estimation"
    sim.user attache le document document1, a: 'work[document2][file]', dans: form_jid
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===

    # --- VÉRIFICATIONS DE L'INTERFACE ---
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message 'votre document a été enregistré et transmis'
    La feuille affiche le message erreur 'Un nom de fichier était trop long, je l\'ai raccourci à 60 caractères.'

    hdocs = dbtable_icdocuments.select(where: "user_id = #{sim.user_id} AND created_at > #{start_time}")
    hdoc = hdocs.first
    expect(hdoc[:original_name]).not_to eq ndoc
    expect(hdoc[:original_name]).to eq 'Ceci_est_un_document_avec_un_nom_vraiment_trop_long_qui_doit.doc'

  end













  scenario 'Une icarienne envoie deux documents normalement' do

    test 'Une icarienne envoie deux documents normalement, puis re-soumet la page (=> erreur)'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    upwd =    'motdepasse'
    sim = Simulate.new
    sim.after_start_module(password: upwd, module: 2, test: false, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 2
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd

    ndoc1_final = 'Travail_1_etape_1.odt'
    ndoc2_final = 'Un_travail_etape.doc'
    document1 = 'Travail 1 étape 1.odt'.in_folder_document
    document2 = 'Un travail étape.doc'.in_folder_document

    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user choisit '10/20', dans: "#{form_jid} select#work_document1_estimation"
    sim.user attache le document document1, a: 'work[document1][file]', dans: form_jid
    sim.user attache le document document2, a: 'work[document2][file]', dans: form_jid
    sim.user choisit '15/20', dans: "#{form_jid} select#work_document2_estimation"
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===

    # --- VÉRIFICATIONS DE L'INTERFACE ---
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message "Merci #{pseudo}, vos 2 documents ont été enregistrés et transmis."

    # --- VÉRIFICATION DES DONNÉES (ENREGISTRÉES) ---
    drequest = {where: "user_id = #{sim.user_id} AND created_at > #{start_time}"}
    hdocuments = dbtable_icdocuments.select(drequest)
    expect(hdocuments.count).to eq 2
    success '2 documents ont été enregitrés'
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc1_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc2_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    success 'Les données des deux documents sont valides'

    docs_ids = hdocuments.collect{|h| h[:id]}
    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq docs_ids.join(' ')
    success 'La donnée @documents de l’icétape est valide.'

    dwatcher = {objet_id: docs_ids.first, objet: 'ic_document', processus: 'admin_download'}
    expect(u).to have_watcher dwatcher
    dwatcher.merge!(objet_id: docs_ids.last)
    expect(u).to have_watcher dwatcher
    success '1 watcher a bien été créé pour chaque document.'

    # ---------------------------------------------------------------------
    #   L'ICARIENNE RECHARGE LA PAGE
    # ---------------------------------------------------------------------
    sim.user recharge

    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message erreur 'Vous demandez une action inconnue'

    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq docs_ids.join(' ')
    expect(icetape.documents.split(' ').count).to eq 2
    success 'La donnée @documents de l’icétape est toujours valide.'

    drequest = "user_id = #{sim.user_id} AND created_at > #{start_time}"
    hdocuments = dbtable_icdocuments.select(drequest)
    expect(hdocuments.count).to eq 2
    success 'Aucun nouveau document n’a été enregitré.'

    drequest = {where: {objet: 'ic_document', user_id: sim.user_id, processus: 'admin_download'} }
    expect(dbtable_watchers.count(drequest)).to eq 2
    success 'Il y a toujours seulement deux watchers de documents.'
  end








  scenario 'Une icarienne envoie deux documents en oubliant la note du premier' do
    test 'Une icarienne envoie deux documents en oubliant la note du premier'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    sim = Simulate.new
    upwd = 'unpassword' # indispensable pour l'identification future
    sim.after_start_module(password: upwd, module: 3, test: false, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 3
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd

    ndoc1_final = 'Travail_1_etape_1.odt'
    ndoc2_final = 'Un_travail_etape.doc'
    document1 = 'Travail 1 étape 1.odt'.in_folder_document
    document2 = 'Un travail étape.doc'.in_folder_document

    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid

    # L'oubli est ici :
    # sim.user choisit '10/20', dans: "#{form_jid} select#work_document1_estimation"
    sim.user attache le document document1, a: 'work[document1][file]', dans: form_jid
    sim.user attache le document document2, a: 'work[document2][file]', dans: form_jid
    sim.user choisit '15/20', dans: "#{form_jid} select#work_document2_estimation"
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid
    sleep 1

    # === VÉRIFICATIONS ===

    # --- VÉRIFICATIONS DE L'INTERFACE ---
    La feuille a pour titre TITRE_BUREAU
    La feuille ne contient pas le message "Merci #{pseudo}, vos 2 documents ont été enregistrés et transmis."
    La feuille affiche le message erreur 'VOS DOCUMENTS NE POURRONT PAS ÊTRE ENREGISTRÉS SANS CES NOTES'

    # --- VÉRIFICATION DES DONNÉES (ENREGISTRÉES) ---
    drequest = {where: "user_id = #{sim.user_id} AND created_at > #{start_time}"}
    hdocuments = dbtable_icdocuments.select(drequest)
    expect(hdocuments.count).to eq 2
    success 'Les 2 documents ont été quand même enregitrés'
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc1_final}'"}
    hdoc1 = dbtable_icdocuments.get(drequest)
    expect(hdoc1[:cote_original]).to eq nil
    expect(hdoc1).not_to eq nil
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc2_final}'"}
    hdoc2 = dbtable_icdocuments.get(drequest)
    expect(hdoc2).not_to eq nil
    expect(hdoc2[:cote_original]).to eq 1.5
    success 'Les données des deux documents sont valides'

    docs_ids = hdocuments.collect{|h| h[:id]}
    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq nil
    success 'La donnée @documents de l’icétape est nil.'


    dwatcher = {objet_id: docs_ids.first, objet: 'ic_document', processus: 'admin_download'}
    expect(u).not_to have_watcher dwatcher
    success 'Pas de watcher pour le premier document.'
    dwatcher.merge!(objet_id: docs_ids.last)
    expect(u).to have_watcher dwatcher
    success 'Mais un watcher pour le second.'

    La feuille contient le formulaire form_id
    expect(sim.user).to have_watcher(objet: 'ic_etape', processus: 'send_work')
    # Il n'y a plus de champ pour entrer les documents
    La feuille ne contient plus la balise 'input', type: 'file', id: 'work_document1_file', dans: form_jid
    La feuille ne contient plus la balise 'input', type: 'file', id: 'work_document2_file', dans: form_jid
    # Il n'y a plus le select pour entrer la note du second document
    La feuille contient toujours la balise 'select', id: 'work_document1_estimation', dans: form_jid
    La feuille ne contient plus la balise 'select', id: 'work_document2_estimation', dans: form_jid
    success 'La notification d’envoi des documents existe toujours et est valide'

    nb = dbtable_icdocuments.count(where: "user_id = #{sim.user_id} AND created_at > #{start_time}")
    puts "Nombre de documents avant le rechargement : #{nb}"

    # ---------------------------------------------------------------------
    #   ERRREUR : L'ICARIENNE RECHARGE LA PAGE
    # ---------------------------------------------------------------------
    sim.user recharge
    sleep 0.5

    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message erreur 'Merci de ne pas recharger la page'

    nb = dbtable_icdocuments.count(where: "user_id = #{sim.user_id} AND created_at > #{start_time}")
    expect(nb).to eq 2
    success 'Aucun enregistrement supplémentaire de document ne s’est produit'

    # ---------------------------------------------------------------------
    #   CORRECTION : L'ICARIENNE DÉFINIT LA NoTE
    # ---------------------------------------------------------------------

    sim.user choisit '10/20', dans: "#{form_jid} select#work_document1_estimation"
    shot 'avant-submit-note-doc1'
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===
    La feuille a pour titre TITRE_BUREAU
    shot 'apres-submit-note-doc1'

    # === VÉRIFICATION DES DONNÉES ENREGISTRÉES
    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq docs_ids.join(' ')
    success 'La donnée @documents de l’icétape est valide (elle contient les 2 ids de document).'

    La feuille ne contient plus le formulaire form_jid
    expect(sim.user).not_to have_watcher(objet: 'ic_etape', processus: 'send_work')
    success 'Le watcher d’envoi a bien été supprimé de la base'

    dwatcher = {objet_id: docs_ids.first, objet: 'ic_document', processus: 'admin_download'}
    expect(u).to have_watcher dwatcher
    dwatcher.merge!(objet_id: docs_ids.last)
    expect(u).to have_watcher dwatcher
    success '1 watcher a bien été créé pour chaque document.'

  end














  scenario 'Une icarienne envoie quatre documents (en en sautant un) normalement' do

    test 'Une icarienne envoie 4 documents en sautant un champ, puis recharge la page.'
    start_time = Time.now.to_i - 1

    # Simuler cette icarienne
    upwd =    'passounette'
    sim = Simulate.new
    sim.after_start_module(password: upwd, module: 4, test: false, sexe: 'F')
    pseudo = sim.user.pseudo

    # Les données du watcher d'envoi du travail
    hwtravail = sim.watchers.last

    # puts "\n\nIDENTIFICATION : #{sim.user.mail} / #{upwd}\n\n"

    # === CONTRE-VÉRIFICATIONS AVANT TEST ===
    expect(sim.user.icmodule.abs_module.id).to eq 4
    expect(sim.user.icetape.status).to eq 1
    success "L'étape de #{pseudo} a bien le statut 1 au départ."

    # === TEST ===
    form_id = "form_watcher-#{hwtravail[:id]}"
    form_jid = "form##{form_id}"
    identify mail: sim.user.mail, password: upwd

    ndoc1_final = 'Travail_1_etape_1.odt'
    ndoc2_final = 'Un_travail_etape.doc'
    ndoc3_final = 'Etape_1_de_module_4.pdf'
    ndoc4_final = 'Etape_1.2_du_module_4.pdf'

    document1 = 'Travail 1 étape 1.odt'.in_folder_document
    document2 = 'Un travail étape.doc'.in_folder_document
    document3 = 'Étape 1 de module 4.pdf'.in_folder_document
    document4 = 'Étape 1.2 du module 4.pdf'.in_folder_document

    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user choisit '10/20', dans: "#{form_jid} select#work_document1_estimation"
    sim.user attache le document document1, a: 'work[document1][file]', dans: form_jid
    sim.user attache le document document2, a: 'work[document2][file]', dans: form_jid
    sim.user choisit '15/20', dans: "#{form_jid} select#work_document2_estimation"
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user clique le link '+', dans: form_jid
    sim.user choisit '12/20', dans: "#{form_jid} select#work_document4_estimation"
    sim.user attache le document document3, a: 'work[document4][file]', dans: form_jid
    sim.user attache le document document4, a: 'work[document5][file]', dans: form_jid
    sim.user choisit '8/20', dans: "#{form_jid} select#work_document5_estimation"
    shot 'before-submit-4-documents'
    sim.user clique le bouton 'Envoyer le travail', dans: form_jid

    # === VÉRIFICATIONS ===

    # --- VÉRIFICATIONS DE L'INTERFACE ---
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message "Merci #{pseudo}, vos 4 documents ont été enregistrés et transmis."

    # --- VÉRIFICATION DES DONNÉES (ENREGISTRÉES) ---
    drequest = {where: "user_id = #{sim.user_id} AND created_at > #{start_time}"}
    hdocuments = dbtable_icdocuments.select(drequest)
    expect(hdocuments.count).to eq 4
    success '4 documents ont été enregitrés'
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc1_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc2_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc3_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    drequest = {where: "user_id = #{sim.user_id} AND original_name = '#{ndoc4_final}'"}
    expect(dbtable_icdocuments.get(drequest)).not_to eq nil
    success 'Les données des deux documents sont valides'

    docs_ids = hdocuments.collect{|h| h[:id]}
    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq docs_ids.join(' ')
    expect(icetape.documents.split(' ').count).to eq 4
    success 'La donnée @documents de l’icétape est valide.'

    dwatcher = {objet_id: docs_ids.first, objet: 'ic_document', processus: 'admin_download'}
    expect(u).to have_watcher dwatcher
    dwatcher.merge!(objet_id: docs_ids[1])
    expect(u).to have_watcher dwatcher
    dwatcher.merge!(objet_id: docs_ids[2])
    expect(u).to have_watcher dwatcher
    dwatcher.merge!(objet_id: docs_ids[3])
    expect(u).to have_watcher dwatcher
    success '1 watcher a bien été créé pour chacun des 4 documents.'

    # ---------------------------------------------------------------------
    #   L'ICARIENNE RECHARGE LA PAGE
    # ---------------------------------------------------------------------
    sim.user recharge

    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message erreur 'Vous demandez une action inconnue'

    u = User.new(sim.user_id)
    icetape = u.icetape
    expect(icetape.documents).to eq docs_ids.join(' ')
    expect(icetape.documents.split(' ').count).to eq 4
    success 'La donnée @documents de l’icétape est toujours valide.'

    drequest = "user_id = #{sim.user_id} AND created_at > #{start_time}"
    hdocuments = dbtable_icdocuments.select(drequest)
    expect(hdocuments.count).to eq 4
    success 'Aucun nouveau document n’a été enregitré.'

    drequest = {where: {objet: 'ic_document', user_id: sim.user_id, processus: 'admin_download'} }
    expect(dbtable_watchers.count(drequest)).to eq 4
    success 'Il y a toujours seulement deux watchers de documents.'
  end


end
