feature "Paiement correct effectué" do
  scenario "Benoit peut payer son module d'apprentissage" do
    test 'Benoit peut payer son module d’apprentissage'

    start_time = Time.now.to_i - 1

    resultat = benoit.set_actif(
      abs_module_id:      1,
      since:              30,
      paiement_required:  true
    )

    # On récupère l'ID du watcher de paiement
    watcher_paie_id = resultat[:watcher_paiement_id]

    expect(benoit).not_to be_real_icarien
    expect(benoit).to be_alessai
    success "Benoit n'est pas un vrai icarien, il est à l'essai."

    identify_benoit

    La feuille a pour titre TITRE_BUREAU

    La feuille contient la balise( 'ul', class: 'notifications',
      success:  'Benoit trouve la liste de ses notifications')

    La feuille affiche("vous pouvez procéder aujourd'hui au paiement de votre module", in: "li#li_watcher-#{watcher_paie_id}",
      success: 'Benoit trouve la notification pour son paiement')

    within("li#li_watcher-#{watcher_paie_id}") do
      click_button( 'Payer' )
    end

    La feuille a pour titre TITRE_PAGE_PAIEMENT

    La feuille contient le formulaire 'form_paiement'

    La feuille affiche "paiement du module “#{benoit.icmodule.abs_module.name}”"

    La feuille affiche "Procéder au paiement", in: 'form#form_paiement'

    page.find('form#form_paiement').click
    puts 'Benoit clique sur le formulaire de paiement du module.'

    # LA PROCÉDURE PAYPAL
    TPayPal.do_operation_paypal(pseudo: benoit.pseudo, verbose: false)
    until page.has_css?('section#footer')
      sleep 1
    end
    shot 'retour-site-after-paiement'

    # === VÉRIFICATION ===

    La feuille a pour titre TITRE_PAGE_PAIEMENT
    La feuille affiche 'Votre paiement a été effectué avec succès'
    La feuille affiche 'Nous vous remercions de votre confiance et vous souhaitons bonne continuation au sein de l\'atelier Icare'
    La feuille contient la balise 'table', id: 'facture'
    La feuille contient la balise 'td', text: 'N° Facture', in: 'table#facture'

    # Vérification de la donnée paiement
    nombre_paiements = table_paiements.count(where: {user_id: benoit.id})
    expect(nombre_paiements).to eq 1
    hpaie = table_paiements.get(where: {user_id: benoit.id})
    expect(hpaie).not_to eq nil
    expect(hpaie[:montant]).to eq benoit.icmodule.abs_module.tarif
    success "Il y a un paiement valide pour Benoit (##{hpaie[:id].inspect})"

    # Vérification de la donnée icmodule
    hmod = table_icmodules.get(where: {user_id: benoit.id})
    expect(hmod).not_to eq nil
    expect(hmod[:paiement]).to eq nil
    success 'Le prochain paiement du module a été mis à nil (pas de prochain paiement).'
    lespaiements = hmod[:paiements]
    expect(lespaiements).not_to eq nil
    expect(lespaiements).to eq "#{hpaie[:id]}"
    success 'Le module a bien enregistré le paiement.'

    benoit.recoit_le_mail(
      subject:      'Confirmation de votre paiement',
      sent_after:   start_time,
      message:      ["Merci d'avoir procédé au paiement de #{hpaie[:montant]} € "]
    )
    phil.recoit_le_mail(
      sent_after:   start_time,
      subject:      'Nouveau paiement',
      message:      ["#{benoit.pseudo} (##{benoit.id})", "#{hpaie[:montant]}", benoit.icmodule.abs_module.name]
    )

    # Le watcher a été détruit
    expect(table_watchers.get(watcher_paie_id)).to eq nil
    success 'Le watcher de paiement a été supprimé'

    # Aucun nouveau watcher n'a été créé pour un paiement
    drequest = {where: {user_id: benoit.id, processus: 'paiement'}}
    expect(table_watchers.count(drequest)).to eq 0
    success 'Aucun nouveau watcher paiement n’a été défini pour Benoit'

    # Benoit est considéré comme un vrai icarien
    expect(benoit).to be_real_icarien
    expect(benoit).not_to be_alessai
    success 'Benoit est devenu un vrai icarien, il n’est plus à l’essai.'

    # Une actualité doit avoir été produite pour cette nouvelle
    # inscription PUISQUE C'EST UN NOUVEL ICARIEN
    hactu = table_actualites.select(where: "created_at > #{start_time}")
    expect(hactu).not_to be_empty
    expect(hactu.count).to eq 1
    actu = hactu.first
    expect(actu[:message]).to eq "<strong>#{benoit.pseudo}</strong> devient un <em>vrai</em> icarien."
    success 'Une dernière actualité annonce que Benoit est devenu vrai icarien.'
  end


  scenario 'Benoit suivant un module à DI paie son module' do

    # === VÉRIFICATIONS ===

    # TODO La page indique à Benoit la prochaine date de paiement
    # TODO next_paiement a été mis à la date de prochain paiement
    # TODO Un autre watcher de paiement a été créé
  end
end
