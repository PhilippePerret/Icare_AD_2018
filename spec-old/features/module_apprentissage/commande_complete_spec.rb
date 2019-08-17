=begin

  Module qui envisage le scénario complet de la commande d'un module
  d'apprentissage avec réussite

=end
feature "Commande complete d'un module" do
  scenario "Benoit commande un module qui lui est attribué" do

    start_time = Time.now.to_i
    test 'Benoit vient commander le module 2'

    # ---------------------------------------------------------------------
    #   À faire par prudence avant
    # ---------------------------------------------------------------------
    benoit.set_inactif

    # ---------------------------------------------------------------------
    #   Benoit commande un module d'apprentissage
    # ---------------------------------------------------------------------
    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    Benoit clique le link 'ACCUEIL'
    Benoit clique le link 'Modules d’apprentissage'
    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE
    Benoit clique le link 'Postuler', dans: 'li#absmodule-2'
    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE
    La feuille a pour soustitre 'Postuler'

    # ---------------------------------------------------------------------
    #   Benoit retourne dans son bureau et trouve la note
    # ---------------------------------------------------------------------
    hw = get_last_watcher benoit
    watcher_command_id = hw[:id]
    Benoit clique le link 'BUREAU'
    La feuille a pour titre TITRE_BUREAU
    La feuille contient le formulaire "form_watcher-#{watcher_command_id}"
    Benoit clique le link 'Déconnexion'

    # ===============================================================

    hwatcher = get_last_watcher benoit
    watcher_id = hwatcher[:id]
    expect(hwatcher[:processus]).to eq 'command'
    expect(hwatcher[:user_id]).to eq benoit.id
    success 'Le watcher de commande existe et appartient à Benoit.'

    datamail = {sent_after: start_time, subject: 'Commande d’un module d’apprentissage'}
    Phil recoit le mail datamail

    # ================================================================

    # ---------------------------------------------------------------------
    #   Phil vient valider la commande du module
    # ---------------------------------------------------------------------
    test 'Phil vient attribuer le module d’apprentissage commandé'
    identify_phil
    La feuille a pour titre TITRE_BUREAU
    form_id   = "form_watcher-#{watcher_id}"
    form_jid  = "form##{form_id}"
    La feuille contient le formulaire form_id
    La feuille contient le bouton 'Attribuer', dans: form_jid
    Phil clique le bouton 'Attribuer', dans: form_jid
    La feuille a pour titre TITRE_BUREAU
    site.require_objet 'abs_module'
    absmodule = AbsModule.new(2)
    La feuille affiche le message "Module “#{absmodule.name}” attribué à #{benoit.pseudo}"
    La feuille ne contient plus le formulaire form_id
    Phil clique le link 'Déconnexion'

    # ==============================================================
    hwatcher = get_last_watcher benoit
    expect(hwatcher[:processus]).to eq 'start'
    expect(hwatcher[:objet]).to eq 'ic_module'
    success 'Benoit possède un watcher pour démarrer son module'

    hicmod = dbtable_icmodules.select(where: {user_id: benoit.id, abs_module_id: 2}, order: 'created_at DESC', limit: 1).first
    expect(hicmod).not_to eq nil
    expect(hicmod[:options][0].to_i).to eq 0
    success 'Un module vient d’être attribué à Benoit, prêt à être démarré'

    data_mail = {sent_after: start_time, subject: 'Réservation de module refusée'}
    Benoit ne recoit pas le mail data_mail
    data_mail = {sent_after: start_time, subject: 'Un module vous a été attribué'}
    Benoit recoit le mail data_mail

    # ==============================================================

    # ---------------------------------------------------------------------
    #   Benoit vient démarrer son module
    # ---------------------------------------------------------------------
    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    form_id   = "form_watcher-#{hwatcher[:id]}"
    form_jid  = "form##{form_id}"
    La feuille contient le formulaire form_id
    La feuille contient le bouton 'Démarrer le module', dans: form_jid
    La feuille ne contient plus le formulaire "form_watcher-#{watcher_command_id}",
      success: 'Benoit n’a plus de notification de commande de module.'


  end
end
