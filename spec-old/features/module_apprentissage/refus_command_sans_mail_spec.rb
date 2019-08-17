=begin

  Module qui envisage le scénario complet de la commande d'un module
  d'apprentissage avec réussite

=end
feature "Commande complete d'un module" do
  scenario "Benoit commande un module qui lui est attribué" do

    # Par prudence :
    #   - on détruit tous les watchers de benoit
    #   - on s'assure que Benoit n'ait pas de module
    dbtable_watchers.delete(where: {user_id: benoit.id})
    dbtable_icmodules.delete(where: {user_id: benoit.id})
    benoit.set(icmodule_id: nil)

    start_time = Time.now.to_i
    test 'Benoit vient commander le module 5'

    # ---------------------------------------------------------------------
    #   Benoit commande un module d'apprentissage
    # ---------------------------------------------------------------------
    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    Benoit clique le link 'ACCUEIL'
    Benoit clique le link 'Modules d’apprentissage'
    La feuille a pour titre TITRE_MODULES_APPRENTISSAGE
    Benoit clique le link 'Postuler', dans: 'li#absmodule-5'
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
    expect(hwatcher[:objet_id]).to eq 5
    expect(hwatcher[:user_id]).to eq benoit.id
    success 'Le watcher de commande existe et appartient à Benoit.'

    datamail = {sent_after: start_time, subject: 'Commande d’un module d’apprentissage'}
    Phil recoit le mail datamail

    # ================================================================

    # ---------------------------------------------------------------------
    #   Phil vient valider la commande du module
    # ---------------------------------------------------------------------
    test 'Phil vient refuser le module d’apprentissage commandé sans motif'
    identify_phil
    La feuille a pour titre TITRE_BUREAU
    form_id   = "form_watcher-#{watcher_id}"
    form_jid  = "form##{form_id}"
    La feuille contient le formulaire form_id
    La feuille contient le bouton 'Attribuer', dans: form_jid
    La feuille contient le bouton 'Refuser', dans: form_jid
    Phil clique le bouton 'Refuser', dans: form_jid
    La feuille a pour titre TITRE_BUREAU
    # sleep 10
    # La feuille ne contient plus le bouton 'Attribuer', dans: form_jid
    La feuille contient le bouton 'Non, accepter', dans: form_jid
    # Je refuse pour de bon
    Phil coche le checkbox 'command[no_mail]', dans: form_jid
    Phil clique le bouton 'Refuser', dans: form_jid
    La feuille a pour titre TITRE_BUREAU

    site.require_objet 'abs_module'
    absmodule = AbsModule.new(5)
    La feuille affiche le message "Module “#{absmodule.name}” REFUSÉ à #{benoit.pseudo}"
    La feuille ne contient plus le formulaire form_id
    Phil clique le link 'Déconnexion'

    # ==============================================================

    where = "user_id = #{benoit.id} AND abs_module_id = 5 AND created_at > #{start_time}"
    hicmod = dbtable_icmodules.select(where: where).first
    expect(hicmod).to eq nil
    success 'Aucun module ne doit avoir été attribué à Benoit'

    where = "user_id = #{benoit.id} AND objet = 'ic_module' AND processus = 'start' AND created_at > #{start_time}"
    expect(dbtable_watchers.count(where: where)).to eq 0
    success 'Aucun watcher pour démarrer le module n’a été créé pour Benoit.'

    data_mail = {sent_after: start_time, subject: 'Un module vous a été attribué'}
    Benoit ne recoit pas le mail data_mail
    data_mail = {sent_after: start_time, subject: 'Réservation de module refusée'}
    Benoit ne recoit pas le mail data_mail # <=== différence ici
    # ==============================================================

    # ---------------------------------------------------------------------
    # Benoit revient mais ne trouve pas de bouton de démarrage

    identify_benoit
    La feuille a pour titre TITRE_BUREAU
    La feuille ne contient pas le bouton 'Démarrer le module', dans: 'ul.notifications'
  end
end
