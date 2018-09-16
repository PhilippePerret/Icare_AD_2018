
feature "Refus d'un candidat" do
  scenario "L'administrateur peut accepter un candidat et lui attribuer un module" do
    test 'L’administrateur peut accepter un candidat et lui attribuer un module'

    start_time = Time.now.to_i

    sim = Simulate.new

    upwd = "unmotdepasse" # on en aura besoin à la fin
    args = {password: upwd, sexe: 'F', test: true}
    sim.inscription args

    newu_id   = sim.user_id
    hw_valid  = sim.watchers.first
    wid       = hw_valid[:id]

    expect(dbtable_icmodules.count(where: {user_id: newu_id})).to eq 0
    success 'L’user n’a pas de module d’apprentissage'
    expect(dbtable_paiements.count(where: {user_id: newu_id})).to eq 0
    success('L’user n’a pas de paiement enregistré')
    request = {where: {user_id: newu_id, processus: 'paiement'}}
    expect(dbtable_watchers.count(request)).to eq 0
    success 'L’user n’a pas de watcher de paiement'

    # L'administrateur rejoint son bureau
    identify_phil

    La feuille a pour titre TITRE_BUREAU

    # Balise LI contenant le watcher concerné
    li_id   = "li_watcher-#{wid}"
    li_jid  = "li#li_watcher-#{wid}"

    La feuille contient la balise 'ul', id: 'watchers-user-1',
      success: 'La page contient la liste des notifications'
    La feuille contient la balise 'li', id: li_id, in: 'ul#watchers-user-1',
      success: 'La page contient la notification pour valider/invalider l’inscription.'

    fjid = "form#form_watcher-#{wid}"

    # On produit volontairement une erreur avec un choix ambigu :
    # L'administrateur ne choisit pas de module et ne donne pas de motif de
    # refus.
    Phil clique le bouton 'OK', in: fjid
    La feuille affiche le message erreur "Choix ambigu"

    # Ensuite, on choisit un module
    inselect = "#{fjid} select#module_choisi-#{wid}"
    Phil selectionne le menu 'Dynamique narrative', dans: inselect
    Phil selectionne le menu '1', dans: inselect
    Phil clique le bouton 'OK', dans: "form#form_watcher-#{wid}"

    # => Confirmation de l'inscription acceptée
    La feuille a pour titre TITRE_BUREAU

    duser = dbtable_users.get(newu_id)

    message_confirmation = "Inscription de #{duser[:pseudo]} (##{newu_id}) confirmée et module “Analyse de film” (#1) attribué"
    La feuille affiche le message message_confirmation
    La feuille ne contient plus la balise 'li', id: li_id

    # => Destruction du watcher d'attribution de module
    expect(dbtable_watchers.count(where: {id: wid})).to eq 0
    success 'Le watcher de validation d’inscription a été détruit.'

    @newu_id = newu_id
    def Newu chaine
      Someone.new({user_id: @newu_id}, chaine).evaluate
    end

    data_mail = {sent_after: start_time, subject: 'Votre candidature a été retenue',
    message: ['J\'ai le plaisir de vous annoncer', "Vous allez donc pouvoir suivre le <strong>module Analyse de film</strong>"]}
    Newu recoit le mail data_mail

    drequest = {where: {user_id: newu_id, message: "<strong>#{duser[:pseudo]}</strong> est reçu#{duser[:sexe]=='H' ? '' : 'e'} à l'atelier."}}
    expect(table_actualites.count(drequest)).to eq 1
    success 'Une actualité annonce la validation de la candidature de l’user'

    newu = User.new(newu_id)
    expect(newu).to be_recu
    expect(newu.options[16].to_i).to eq 4
    success 'L’user est marqué reçu.'

    expect(table_icmodules.count(where: {user_id: newu_id})).to eq 1
    hmod = table_icmodules.get(where: {user_id: newu_id})
    expect(hmod[:next_paiement]).to eq nil
    expect(hmod[:icetape_id]).to eq nil
    expect(hmod[:options][0].to_i).to eq 0
    success 'L’user possède maintenant un module d’apprentissage avec les bonnes données'

    drequest = {where: {user_id: newu_id, processus: 'start', objet: 'ic_module', objet_id: hmod[:id]}}
    expect(table_watchers.count(drequest)).to eq 1
    success 'L’user possède un watcher pour démarrer son module d’apprentissage'

    expect(table_paiements.count(where: {user_id: newu_id})).to eq 0
    success('L’user n’a pas de paiement enregistré')

    request = {where: {user_id: newu_id, processus: 'paiement'}}
    expect(table_watchers.count(request)).to eq 0
    success 'L’user n’a toujours pas de watcher de paiement'

    puts "\n\nPour voir ce que donne à présent le bureau de #{duser[:user]}, régler KEEP_BASES_AFTER_TEST à true dans spec_helper puis connectez-vous avec les identifiants :"
    puts "Mails : #{duser[:mail]}"
    puts "Code  : #{upwd}"

  end

end
