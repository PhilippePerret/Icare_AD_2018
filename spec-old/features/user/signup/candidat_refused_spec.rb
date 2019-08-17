
feature "Refus d'un candidat" do
  scenario "On peut refuser un candidat" do

    test 'L’administrateur peut refuser un candidat'

    start_time = Time.now.to_i - 1

    sim = Simulate.new
    args = { sexe: 'F', test: true }
    sim.inscription args

    # On récupère les informations de la simulation
    watcher_validation = sim.watchers.first
    wid = watcher_validation[:id]
    newu_id = sim.user_id.freeze

    # On récupère ici le mail pour savoir
    umail = sim.user.mail
    # On récupère l'instance user, en activant son mail et son
    # pseudo, pour tester la fin, quand l'user aura été détruit dans la
    # base de données
    u = User.new(newu_id)
    u.mail; u.pseudo; u.sexe;

    # L'administrateur rejoint son bureau
    identify_phil

    La feuille a pour titre TITRE_BUREAU
    La feuille contient la balise 'ul', id: 'watchers-user-1',
      success: 'La page contient la liste des notifications de l’administrateur'
    La feuille contient la balise 'li', id: "li_watcher-#{wid}", in: 'ul#watchers-user-1',
      success: 'La page contient la notification pour valider/invalider l’inscription.'

    fjid = "form#form_watcher-#{wid}"

    # On produit volontairement une erreur avec un choix ambigu :
    # L'administrateur ne choisit pas de module et ne donne pas de motif de
    # refus.
    Phil clique le bouton 'OK', in: fjid
    La feuille affiche le message erreur "Choix ambigu"

    inselect = "#{fjid} select#module_choisi-#{wid}"
    Phil selectionne le menu 'Aucun (refus)', dans: inselect

    @motif_refus = "Le motif du refus à #{Time.now}"
    Phil remplit le champ 'refus[motif]', with: @motif_refus, dans: fjid
    Phil clique le bouton 'OK', in: "form#form_watcher-#{wid}"

    # => Confirmation de la destruction
    La feuille a pour titre TITRE_BUREAU
    La feuille affiche le message 'Inscription détruite.'

    # Destruction de l'user du départ
    expect(dbtable_users.count(where: {id: newu_id})).to eq 0
    success 'Le user a été détruit de la base.'

    # => Destruction du watcher d'attribution de module
    expect(dbtable_watchers.count(where: {id: wid})).to eq 0
    success 'Le watcher de validation de l’inscription a été détruit.'

    data_mail = {
      sent_after:   start_time,
      subject:      'Refus de candidature',
      message:      ['Nous avons le regret de vous annoncer que votre candidature à l\'atelier Icare vient d\'être malheureusement refusée']
    }

    # Phil ne reçoit pas le mail de refus (mis ici car ça se produisait, avant)
    Phil ne recoit pas le mail data_mail

    # L'user a reçu un mail de confirmation
    # Note : comme il a été détruit, on ne peut plus l'interroger par
    # le biais des chaines littéraires. Il faut passer par le test
    # traditionnel
    u.recoit_le_mail(data_mail)

  end

end
