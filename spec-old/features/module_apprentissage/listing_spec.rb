feature "Listing des modules d'apprentissage" do
  scenario "La route abs_modules/list conduit à un listing des modules d'apprentissage conforme" do
    test 'abs_modules/list pour conduire à la liste des modules d’apprentissage'

    site.require_objet 'abs_module'

    visit_home

    La feuille contient le link 'Modules d’apprentissage'
    Benoit clique sur le link 'Modules d’apprentissage'

    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE

    AbsModule.each do |hmodule|

      li_id = "absmodule-#{hmodule[:id]}"
      li_jid = "li##{li_id}"

      La feuille contient la balise 'li', id: li_id, class: 'absmodule',
        success: "La page contient le div du module #{hmodule[:name]}"
      La feuille contient le link 'Postuler', dans: li_jid
      La feuille contient la balise 'span', class: 'tarif', dans: li_jid
      La feuille contient la balise 'span', class: 'duree', dans: li_jid

      La feuille ne contient pas la balise 'div', class: 'shortdesc', dans: li_jid
      La feuille ne contient pas la balise 'div', class: 'longddesc', dans: li_jid

      La feuille contient le link 'Détail', dans: li_jid
      Benoit clique le link 'Détail', dans: li_jid
      La feuille contient la balise 'div', class: 'shortdesc', dans: li_jid
      La feuille ne contient pas la balise 'div', class: 'longdesc', dans: li_jid
      La feuille contient le link 'Encore plus de détail', dans: li_jid
      success 'En cliquant sur “détail” on fait apparaitre la description courte'

      Benoit clique sur le link 'Encore plus de détail', dans: li_jid
      La feuille contient la balise 'div', class: 'longdesc', dans: li_jid
      success "En cliquant sur “Encore plus de détail” on fait apparaitre la descriptioin longue."

    end

  end
  # /Simple consultation

  scenario 'On peut commander un module quand on n’est pas inscrit' do
    test 'Un visiteur arrive et commande un module'

    visit_home
    Benoit clique le link 'Modules d’apprentissage'
    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE

    li_id = "absmodule-4"
    li_jid  = "li#absmodule-4"
    Benoit clique le link 'Postuler', dans: li_jid

    shot 'after-command-module-non-inscrit'
    La feuille a pour titre TITRE_INSCRIPTION,
      success: 'Le visiteur est dirigé vers le formulaire d’inscription.'

  end
  # /Test du choix d'un module par un non inscrit

  scenario 'Un inscrit qui choisit un module' do
    start_time = Time.now.to_i - 1
    test 'Un inscrit à l’atelier peut commander un module'

    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    Benoit clique sur le link 'ACCUEIL'
    La feuille contient le link 'Modules d’apprentissage'

    Benoit clique sur le link 'Modules d’apprentissage'
    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE
    Benoit clique sur le link 'Postuler', dans: "li#absmodule-3"

    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE
    La feuille a pour soustitre 'Postuler'

    La feuille affiche "La requête a été transmise à Phil"
    La feuille affiche "vous informera très rapidement de la réponse donnée à votre demande"

    expect(benoit).to have_watcher(
      objet: 'abs_module', objet_id: 3, processus: 'command'
    )
    success 'Un watcher a été créé pour commander le module'

    data_mail = {sent_after: start_time, subject: 'Commande d’un module d’apprentissage'}
    Phil recoit le mail data_mail

    # Quand il retourne sur son bureau Benoit trouve un watcher qui lui
    # permet d'annuler la commande du module
    hwatcher = dbtable_watchers.select(limit: 1, order: 'created_at DESC').first
    Benoit clique le link 'BUREAU'
    La feuille a pour titre TITRE_BUREAU
    form_id   = "form_watcher-#{hwatcher[:id]}"
    form_jid  = "form##{form_id}"
    La feuille contient le formulaire form_id,
      success: 'Une notification confirme à l’icarien sa commande.'
    La feuille contient le bouton 'Annuler ce module', dans: form_jid,
      success: 'Un bouton permet à l’icarien d’annuler la commande'
  end
end
