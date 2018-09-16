=begin

  Test du démarrage d'un module

=end
feature "Démarrage d'un module" do


  scenario "Benoit rejoint l'atelier et démarre son module" do
    test 'Benoit rejoint d’atelier et démarre son module'

    start_time = Time.now.to_i

    # Pour vérifier la classe de l'ic-étape de l'user.
    site.require_objet 'ic_etape'

    # SIMULATION INSCRIPTION ET VALIDATION
    # -------------------------------------
    # L'user s'est inscrit, son inscription a été validé par
    # l'administrateur et un module lui a été affecté. Il peut
    # maintenant le démarré
    sim = Simulate.new
    $upwd = 'monmotdepasse'
    args = {test: true, password: $upwd, sexe: 'F'}
    sim.pre_start_module args
    user_id = sim.user_id.freeze
    pseudo  = sim.user.pseudo
    # Le premier watcher est celui de la validation de l'inscription
    # hwatcher_valid    = simulate.watchers[0]
    hwatcher_start  = sim.watchers[1]
    wid = hwatcher_start[:id]

    whereclause = "user_id = #{sim.user_id} AND created_at > #{start_time} AND message LIKE '%démarre son module d’apprentissage%' AND message LIKE '%#{pseudo}%'"
    expect(dbtable_actualites.count(where: whereclause)).to eq 0
    success 'Aucune actualité n’annonce le démarrage du module d’apprentissage.'

    expect(sim.user).to be_inactif
    expect(sim.user).not_to be_actif
    success "#{pseudo} est un icarien inactif."

    hmod = dbtable_icmodules.get(where: {user_id: sim.user_id})
    expect(hmod[:options][0].to_i).to eq 0
    success 'Le module d’apprentissage n’est pas marqué en cours.'

    expect(hmod[:started_at]).to eq nil
    success 'Le module a une date de démarrage nil'

    expect(dbtable_icetapes.count(where:{user_id: user_id})).to eq 0
    success "#{pseudo} n'a pas d'icetapes dans la table"

    expect(sim.user.icetape).to eq nil
    success "La propriété @icetape de #{pseudo} est nil."

    identify mail: sim.user.mail, password: $upwd


    La feuille a pour titre TITRE_BUREAU
    shot 'after-login-new-icarien'

    La feuille contient la balise 'span', class: 'user_state', text: 'inactif', in: 'div#div_user_state',
      success: "Le statut inactif de #{pseudo} est indiqué sur son bureau."

    La feuille contient la balise 'ul', id: "watchers-user-#{user_id}",
      success: "#{pseudo} trouve sa liste de notifications."
    La feuille contient la balise 'li', id: "li_watcher-#{wid}",
      success: "#{pseudo} trouve la notification de démarrage de son module."


      sleep 1

    # === TEST ===
    formjid = "form#form_watcher-#{wid}"
    sim.user clique le bouton 'Démarrer le module', dans: formjid


    sleep 1
      # Noter que si on met trop longtemps, le message ci-dessus (confirmation)
      # aura disparu

    # === VÉRIFICATIONS ===

    La feuille a pour titre TITRE_BUREAU
    shot 'after-start-module'
    La feuille affiche le message "Bravo #{pseudo}, votre module d’apprentissage est démarré !",
      success: 'Un message de confirmation est affiché'

    # Prendre un nouvel User
    # (il faut comprendre que celui qui a été modifié n'est pas celui qu'on
    # a pris avant, mais celui qui s'est connecté vraiment sur le site)
    sim.user= User.new(sim.user_id)
    expect(sim.user).not_to be_inactif
    expect(sim.user).to be_actif
    success "#{pseudo} est maintenant un icarien actif."

    # Pour être sûr, on déconnecte et reconnecte l'user
    sim.user clique le link 'Déconnexion'
    identify mail: sim.user.mail, password: $upwd

    # Le bureau indique que l'user est actif
    La feuille contient la balise 'span', class: 'user_state', text: 'actif', in: 'div#div_user_state',
      success: "Le statut ACTIF de #{pseudo} est indiqué sur son bureau."

    icmodule = sim.user.icmodule

    expect(sim.user.icmodule_id).to eq icmodule.id
    success 'La données icmodule_id est bien réglée dans les données de l’icarien'

    opts = icmodule.options
    expect(opts[0].to_i).to eq 1
    success 'Le module d’apprentissage est marqué en cours.'

    expect(icmodule.started_at).to be > start_time
    success 'Le module a une date de démarrage correctement réglée'

    expect(icmodule.icetape_id).not_to eq nil
    success 'L’icétape est réglée pour le module'

    expect(sim.user.icetape).not_to eq nil
    expect(sim.user.icetape).to be_instance_of IcModule::IcEtape
    expect(sim.user.icetape.id).to eq icmodule.icetape_id
    success "#{pseudo} répond à `icetape` qui renvoie une IcModule::IcEtape de l'étape courante"
    # L'user n'a pas d'ic-etape
    drequest = { where: { user_id: user_id,  icmodule_id: sim.user.icmodule.id } }
    hicetape = dbtable_icetapes.get( drequest )
    expect(hicetape).not_to eq nil
    success "#{pseudo} a une ic-étape enregistrée dans la base."

    expect(sim.user.icmodule.icetape_id).to eq hicetape[:id]
    success 'L’ic-étape est définie correctement dans son ic-module'

    # Watcher de paiement
    expect(sim.user).to have_watcher(objet: 'ic_module', processus: 'paiement')
    whereclause = {user_id: sim.user_id, processus: 'paiement'}
    hwatcher = dbtable_watchers.get(where: whereclause)
    expect(hwatcher[:triggered]).to be > (start_time + 1.month - 4.days)
    success "#{pseudo} a un watcher valide pour son paiement de module."

    expect(sim.user).to have_watcher(objet:'ic_etape', processus: 'send_work')
    success "#{pseudo} a un watcher pour remettre ses documents."

    # Une actualité annonçant son démarrage
    whereclause = "user_id = #{sim.user_id} AND created_at > #{start_time} AND message LIKE '%démarre son module d’apprentissage%' AND message LIKE '%#{pseudo}%'"
    expect(dbtable_actualites.count(where: whereclause)).to eq 1
    success 'Une actualité annonce le démarrage du module d’apprentissage.'

    # ---------------------------------------------------------------------
    #   Nouveau bureau de l'icarien (avec l'étape courante)
    # ---------------------------------------------------------------------

    hwa = dbtable_watchers.get(where: {user_id: sim.user_id, processus: 'send_work'})
    waid = hwa[:id]
    wa_li_id  = "li_watcher-#{waid}"
    wa_li_jid = "li##{wa_li_id}"
    La feuille contient la balise 'li', id: wa_li_id,
      success: 'Le bureau contient la notification pour l’envoi des documents.'
    La feuille contient le formulaire "form_watcher-#{waid}", dans: wa_li_jid
    form_jid = "form#form_watcher-#{waid}"
    (1..5).each do |idocument|
      # Attention : ici, si j'arrive un jour à implémenter cette
      # p*** de test de visibilité, ce test produira une erreur car les
      # champs sont marqués. C'est pour cela que je clique sur '+'
      sim.user clique sur le link '+'
      La feuille contient la balise 'input', type: 'file', name: "work[document#{idocument}][file]", dans: form_jid
    end
    success 'Donc le bureau affiche un formulaire d’envoi du travail correct'

    # Le bureau affiche le bloc d'information sur le module avec
    La feuille contient le fieldset 'infos_current_module'
    fsinfos = "fieldset#infos_current_module"
    La feuille contient le fieldset 'infos_current_module'
    success 'Donc, le bureau affiche les infos du module courant'

    icetape = sim.user.icetape

    # sleep 10*60
    # fieldset#current_etape_work
      # div#etape_titre
      # section#section_etape_objectif
      # section#section_etape_travail
      # section#section_etape_mini_faq
      # section#section_etape_qdd
    fswork = "fieldset#current_etape_work"
    La feuille contient le div 'etape_titre',                      dans: fswork
    La feuille contient la section 'section_etape_objectif',       dans: fswork
    La feuille contient la section 'section_etape_travail',        dans: fswork
    if icetape.travail_propre
      La feuille contient la section 'section_etape_travail_propre', dans: fswork
    end
    if icetape.abs_etape.liens
      La feuille contient la section 'section_etape_liens',          dans: fswork
    end
    if icetape.abs_etape.methode
      La feuille contient la section 'section_etape_methode',        dans: fswork
    end
    La feuille contient la section 'section_etape_mini_faq',       dans: fswork
    La feuille contient la section 'section_etape_qdd',            dans: fswork
    success 'Donc la page contient l’affichage correct du travail'

    puts "Pour ce connecter comme ce utilisateur : \nMettre KEEP_BASES_AFTER_TEST à true dans spec_helper avant de lancer le test\nSe connecter avec : #{sim.user.mail} / #{$upwd}"

  end
end
