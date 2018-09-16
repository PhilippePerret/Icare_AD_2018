feature "Test de la création d'une question minifaq, de a à z" do
  scenario 'Un icarien dépose une question mini-faq' do
    test 'Un icarien peut déposer une question mini-faq avec succès'

    start_time = Time.now.to_i

    # ===============================================================
    # On commence par mettre Benoit à l'étape 1 du module 1 (analyse)
    site.require_objet 'ic_module'
    site.require_objet 'ic_etape'
    IcModule.require_module 'create'
    icmodule = IcModule.create_for(benoit, 1) # pas démarré
    icmodule_id = icmodule.id
    icmodule.set(started_at: NOW - 10.days)
    benoit.set(
      options:      benoit.options.set_bit(16,2),
      icmodule_id:  icmodule.id
      )
    icmodule = IcModule.new(icmodule_id)
    icetape = IcModule::IcEtape.create_for( icmodule, 1 )
    icmodule.set(
      icetape_id: icetape.id,
      icetapes:   nil
      )
    # =================================================================

    # ---------------------------------------------------------------------
    #   Vérifications préliminaires
    # ---------------------------------------------------------------------
    dbtable_watchers.delete(where: {user_id: benoit.id, processus: 'reponse_minifaq'})
    nb_watchers = dbtable_watchers.count(where:{user_id: benoit.id, processus: 'reponse_minifaq'})
    expect(nb_watchers).to eq 0

    # === OPÉRATION ===
    identify_benoit

    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire 'minifaq_form'
    laquestion = "La question #{Time.now}."
    form_jid = 'form#minifaq_form'
    Benoit remplit le champ 'minifaq[question]', avec: laquestion, dans: form_jid
    Benoit clique le bouton 'Poser cette question'

    # === VÉRIFICATIONS ===
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message 'Merci pour votre question'

    watcher = dbtable_watchers.get(where: { user_id: benoit.id, processus: 'reponse_minifaq' })
    expect(watcher).not_to eq nil
    expect(watcher[:data]).to eq laquestion
    success 'Un watcher a été créé pour répondre à la question.'

    data_mail = {
      sent_after: start_time, subject: 'Nouvelle question mini-faq',
      message: ["#{benoit.pseudo} (##{benoit.id})", laquestion]
    }
    Phil recoit le mail data_mail

    li_id  = "li_watcher-#{watcher[:id]}"
    li_jid = "li##{li_id}"
    La feuille contient la balise 'li', id: li_id, text: laquestion

  end

  scenario 'Phil peut répondre à la question mini-faq' do

    start_time = Time.now.to_i

    test 'Phil peut répondre pour une question mini-faq'

    # ================================================================
    #     Vérifications préliminaires et création d'un watcher
    # ================================================================
    watchers = dbtable_watchers.select( where: { processus: 'reponse_minifaq' } )

    if watchers.count == 0
      hw = {
        objet:        'abs_etape',
        objet_id:     1,
        processus:    'reponse_minifaq',
        data:         "Une question posée pour la faq à #{Time.now}."
      }
      hw.merge!(id: benoit.add_watcher(hw))
    else
      hw = watchers.last
    end

    laquestion = hw[:data].freeze

    identify_phil

    La feuille a pour titre TITRE_BUREAU

    # Phil trouve le formulaire pour répondre
    form_jid = "form#form_watcher-#{hw[:id]}"
    La feuille contient le formulaire "form_watcher-#{hw[:id]}"
    La feuille contient la balise 'div', class: 'question', text: laquestion
    La feuille contient le menu 'minifaq_destination', name: 'minifaq[destination]', dans: form_jid
    La feuille contient la balise 'textarea', id: 'minifaq_reponse', name: 'minifaq[reponse]', dans: form_jid
    La feuille contient le link 'voir l’étape', dans: form_jid

    # Phil remplit la première réponse
    response = "La réponse de Phil du #{Time.now}".freeze
    Phil remplit le champ 'minifaq_reponse', avec: response, dans: form_jid
    Phil clique le bouton 'OK', dans: form_jid

    La feuille a pour titre TITRE_BUREAU
    # === VÉRIFICATION ===
    La feuille affiche le message 'Réponse enregistrée'

    hqr = dbtable_minifaq.select( where: "created_at > #{start_time}" ).last

    expect(hqr).not_to eq nil

    {
      abs_etape_id:   1,
      abs_module_id:  1,
      numero:         1,
      user_id:        benoit.id,
      user_pseudo:    benoit.pseudo,
      question:       laquestion,
      reponse:        response
    }.each do |prop, value|
      expect(hqr[prop]).to eq value
    end
    success 'Les propriétés de la rangée minifaq sont bonnes.'

    # Le watche ne doit plus exister
    nb = dbtable_watchers.count(where: {id: hw[:id]})
    expect(nb).to eq 0
    success 'Le watcher a été supprimé.'

    data_mail = {
      subject:      'Une réponse à votre question',
      sent_after:   start_time,
      message:      [hw[:data], response, 'Vous pouvez également retrouver cette réponse']
    }
    Benoit recoit le mail data_mail

  end

  scenario 'Phil peut répondre à l’icarien' do
    start_time = Time.now.to_i

    test 'Phil peut répondre à l’icarien sans enregistrer la question dans la minifaq'

    # ================================================================
    #     Vérifications préliminaires et création d'un watcher
    # ================================================================
    nombre_questions_init = dbtable_minifaq.count.freeze
    puts "Le nombre de questions minifaq initial est : #{nombre_questions_init}."

    watchers = dbtable_watchers.select( where: { processus: 'reponse_minifaq' } )

    if watchers.count == 0
      hw = {
        objet:        'abs_etape',
        objet_id:     2,
        processus:    'reponse_minifaq',
        data:         "Une question posée pour la faq à #{Time.now}."
      }
      hw.merge!(id: benoit.add_watcher(hw))
    else
      hw = watchers.last
    end
    # puts "hw : #{hw.inspect}"

    laquestion = hw[:data].freeze

    identify_phil

    La feuille a pour titre TITRE_BUREAU

    # Phil trouve le formulaire pour répondre
    form_jid = "form#form_watcher-#{hw[:id]}"
    La feuille contient le formulaire "form_watcher-#{hw[:id]}"
    La feuille contient la balise 'div', class: 'question', text: laquestion
    La feuille contient le menu 'minifaq_destination', name: 'minifaq[destination]', dans: form_jid
    La feuille contient la balise 'textarea', id: 'minifaq_reponse', name: 'minifaq[reponse]', dans: form_jid
    La feuille contient le link 'voir l’étape', dans: form_jid

    # Phil remplit la première réponse
    response = "La réponse de Phil du #{Time.now}".freeze
    Phil remplit le champ 'minifaq_reponse', avec: response, dans: form_jid
    Phil choisit 'Répondre seulement à l’auteur', dans: "#{form_jid} select#minifaq_destination"
    Phil clique le bouton 'OK', dans: form_jid

    La feuille a pour titre TITRE_BUREAU
    # === VÉRIFICATION ===
    La feuille affiche le message "Réponse envoyée à #{benoit.pseudo}"

    nombre_questions = dbtable_minifaq.count
    expect(nombre_questions).to eq nombre_questions_init
    success 'Aucune question minifaq supplémentaire n’a été enregistrée.'

    # Le watcher n'existe plus
    nb = dbtable_watchers.count( where: {id: hw[:id]} )
    expect(nb).to eq 0
    success 'Le watcher a été supprimé.'

    data_mail = {
      subject:      'Une réponse à votre question',
      sent_after:   start_time,
      message:      [hw[:data], response]
    }
    Benoit recoit le mail data_mail

  end

  scenario 'Phil peut détruire la question' do

    start_time = Time.now.to_i

    test 'Phil peut détruire simplement la question'

    # ================================================================
    #     Vérifications préliminaires et création d'un watcher
    # ================================================================
    nombre_questions_init = dbtable_minifaq.count.freeze
    puts "Le nombre de questions minifaq initial est : #{nombre_questions_init}."

    watchers = dbtable_watchers.select( where: { processus: 'reponse_minifaq' } )

    if watchers.count == 0
      hw = {
        objet:        'abs_etape',
        objet_id:     3,
        processus:    'reponse_minifaq',
        data:         "Une question posée pour la faq à #{Time.now}."
      }
      hw.merge!(id: benoit.add_watcher(hw))
    else
      hw = watchers.last
    end
    # puts "hw : #{hw.inspect}"

    laquestion = hw[:data].freeze

    identify_phil

    La feuille a pour titre TITRE_BUREAU

    # Phil trouve le formulaire pour répondre
    form_jid = "form#form_watcher-#{hw[:id]}"
    La feuille contient le formulaire "form_watcher-#{hw[:id]}"
    La feuille contient la balise 'div', class: 'question', text: laquestion
    La feuille contient le menu 'minifaq_destination', name: 'minifaq[destination]', dans: form_jid
    La feuille contient la balise 'textarea', id: 'minifaq_reponse', name: 'minifaq[reponse]', dans: form_jid
    La feuille contient le link 'voir l’étape', dans: form_jid

    # Phil remplit la première réponse
    response = "La réponse de Phil du #{Time.now}".freeze
    Phil remplit le champ 'minifaq_reponse', avec: response, dans: form_jid
    Phil choisit 'Détruire la question', dans: "#{form_jid} select#minifaq_destination"
    Phil clique le bouton 'OK', dans: form_jid

    La feuille a pour titre TITRE_BUREAU
    # === VÉRIFICATION ===
    La feuille affiche le message "Question détruite"

    nombre_questions = dbtable_minifaq.count
    expect(nombre_questions).to eq nombre_questions_init
    success 'Aucune question minifaq supplémentaire n’a été enregistrée.'

    # Le watcher n'existe plus
    nb = dbtable_watchers.count( where: {id: hw[:id]} )
    expect(nb).to eq 0
    success 'Le watcher a été supprimé.'

    data_mail = {
      subject:      'Une réponse à votre question',
      sent_after:   start_time,
    }
    Benoit ne recoit pas le mail data_mail
  end
end
