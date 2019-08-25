# encoding: UTF-8
=begin
Test de l'inscription d'un candidat
=end

def reset_signup_folder
  FileUtils.rm_rf('./tmp/signup')
end
# Retourne le nombre de dossiers inscription dans tmp/signup
def signups_count
  if File.exists?('./tmp/signup')
    Dir['./tmp/signup/*'].count
  else
    0
  end
end

# Retourne le dernier dossier inscription
def get_last_signup_folder
  if File.exists?('./tmp/signup')
    Dir['./tmp/signup/*'].sort.last
  else
    nil
  end
end

feature "Inscription d'un candidat à l'atelier", current: true do
  before(:all) do
    reset_signup_folder
  end
  context 'sans soumettre aucune donnée' do
    scenario 'ne peut pas candidater à Icare' do
      visit '/'
      click_link("S’INSCRIRE")
      nombre_inscriptions = signups_count
      expect(page).to have_css('h1', text:'Poser sa candidature')
      expect(page).to have_button('Enregistrer et poursuivre l’inscription')
      click_button('Enregistrer et poursuivre l’inscription')
      screenshot('signup-erreurs')
      # Aucun dossier inscription ne doit avoir été construit
      expect(signups_count).not_to eq(nombre_inscriptions + 1)
      # Il doit y avoir des erreurs
      expect(page).to have_css('div#flash div#errors div.error')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Un pseudo est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Votre mail est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Votre code secret est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Le contrôle anti-robot est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Vous devez accepter les Conditions Générales d’Utilisation')
    end
  end

  context 'en soumettant des pseudos invalides' do
    scenario 'ne peut pas s’inscrire à l’atelier' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('h1', text:'Poser sa candidature')
      expect(page).to have_button('Enregistrer et poursuivre l’inscription')

      nombre_inscriptions = signups_count

      [
        ['', 'Un pseudo est requis'],
        ['Phil', 'Ce pseudo est déjà utilisé'],
        ['co', 'Ce pseudo est trop court'],
        ['x'*40, 'Ce pseudo est trop long'],
        ['?pour été ça!', 'Ce pseudo est invalide']
      ].each do |pseudo, err_msg|
        within('form#form_user_signup') do
          fill_in('user[pseudo]', with: pseudo)
          click_button('Enregistrer et poursuivre l’inscription')
        end
        # sleep 2
        expect(page).to have_css('div.error', text: err_msg)
        expect(signups_count).not_to eq(nombre_inscriptions + 1)
        screenshot('signup-erreurs')
      end
    end
  end

  context 'avec des données valides' do
    scenario 'peut s’inscrire à l’atelier' do

      start_time = Time.now

      now = Time.now.to_i.to_s[-7..-1]
      pseudo = "UnPseudo#{now}"
      mail   = "mail#{now}@chez.lui"
      pass   = "#{now}#{now}"

      # Nombre d'inscriptions au départ
      nombre_inscriptions = signups_count

      visit '/'
      click_link("S’INSCRIRE")

      xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
      ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
      captcha = xcap + ycap

      good_data = {
        pseudo:pseudo, mail:mail, mail_confirmation: mail,
        password:pass, password_confirmation:pass,
        captcha:captcha
      }

      # Bonnes données d'identité
      # -------------------------
      within('form#form_user_signup') do
        good_data.each do |prop, value|
          fill_in("user[#{prop}]", with: value)
        end
        select(1992, from: 'user[naissance]')
        check('user[accept_cgu]')
        click_button('Enregistrer et poursuivre l’inscription')
      end
      expect(page).not_to have_css('div#flash div#errors')
      screenshot("signup-good-identity")

      expect(signups_count).to eq(nombre_inscriptions + 1)
      signup_folder = get_last_signup_folder
      identity_file = File.join(signup_folder,'identite.msh')
      # puts "Fichier identité : #{identity_file}"
      identity_data = idata = Marshal.load(File.read(identity_file).force_encoding('utf-8'))
      # puts identity_data.pretty_inspect

      # On vérifie que les données enregistrées dans le dossier
      # d'inscription soient valides
      expect(idata[:pseudo]).to eq pseudo
      expect(idata[:patronyme]).to eq pseudo
      expect(idata[:mail]).to eq mail
      expect(idata[:mail_confirmation]).to eq mail
      expect(idata[:password]).to eq pass
      expect(idata[:password_confirmation]).to eq pass
      expect(idata[:sexe]).to eq 'F'
      expect(idata[:naissance]).to eq 1992

      # On peut passer à la deuxième étape de l'inscription : le
      # choix du module
      expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
      within('form#form_modules') do
        check('signup_modules[2]') # Documents
        check('signup_modules[4]') # Personnages
        click_button('Enregistrer et poursuivre l’inscription')
      end
      # Pas d'erreur
      expect(page).not_to have_css('div#flash div#errors')
      # Les modules choisis ont été ajoutés aux données de la candidature
      modules_file = File.join(signup_folder, 'modules.msh')
      expect(File.exists?(modules_file)).to be true
      modules_data = mdata = Marshal.load(File.read(modules_file))
      # puts "modules_data : #{modules_data.pretty_inspect}"
      # La liste renvoyée par modules_data doit contenir 2 et 4
      expect(modules_data).to include(2)
      expect(modules_data).to include(4)

      # ---------------------------------------------------------------------
      # On passe à l'étape suivante (pour soumettre ses documents)

      presentation_name = 'ma présentation.odt'
      motivation_name   = 'ma motivation.odt'
      presentation_path = File.expand_path(File.join('.','spec','asset','document',presentation_name))
      motivation_path   = File.expand_path(File.join('.','spec','asset','document',motivation_name))
      expect(page).to have_css('h2', text: 'Documents de candidature (3/4)')
      within('form#form_documents') do
        attach_file('signup_documents[presentation]', presentation_path)
        attach_file('signup_documents[motivation]', motivation_path)
        click_button('Enregistrer la candidature')
      end

      # Aucune erreur n'a été rencontrée
      expect(page).not_to have_css('div#flash div#errors')
      # Un fichier contient les données des documents
      documents_file = File.join(signup_folder,'documents.msh')
      expect(File.exists?(documents_file)).to be true
      documents_data = ddata = Marshal.load(File.read(documents_file))
      expect(ddata[:presentation]).to eq 'Document_presentation.odt'
      expect(ddata[:motivation]).to eq 'Document_motivation.odt'
      expect(ddata[:extraits]).to eq nil
      # Les documents ont été placés dans le dossier
      presentation_signup_path = File.join(signup_folder,'documents','Document_presentation.odt')
      expect(File.exists?(presentation_signup_path)).to be true
      motivation_signup_path = File.join(signup_folder,'documents','Document_motivation.odt')
      expect(File.exists?(motivation_signup_path)).to be true
      # Il n'y a pas de document extraits
      extraits_signup_path = File.join(signup_folder,'documents','Document_extraits.odt')
      expect(File.exists?(extraits_signup_path)).to be false

      # On se retrouve sur la page de confirmation de l'inscription
      expect(page).to have_css('h2', text: 'Confirmation du dépôt (4/4)')

      # On doit vérifier que tout a été bien été créé
      # ---------------------------------------------

      # Aucun enregistrement n'a été fait dans la base
      res = DB.execute("SELECT * FROM icare_users.users WHERE created_at > ?", [start_time.to_i])
      expect(res).not_to be_empty
      duser = res.first
      expect(duser[:pseudo]).to eq pseudo
      expect(duser[:mail])  .to eq mail
      user_id = duser[:id]

      # Un watcher a été créé pour l'administrateur
      dwatcher = {user_id:user_id, objet:'user', objet_id:user_id, processus:'valider_inscription'}
      dwatcher = watcher_should_exist(dwatcher)
      # puts "---DWATCHER: #{dwatcher.inspect}"
      session_id = dwatcher[:data]
      # Ça doit être le nom du dossier
      expect(dwatcher[:data]).to eq File.basename(signup_folder)

      # Une actualité a dû être créée
      dactu = {user_id:user_id, message: "Inscription de <strong>#{pseudo}</strong>."}
      dactu = actualite_should_exist(dactu)
      # puts "--- ACTU: #{dactu.inspect}"

      # Un mail a dû être envoyé à l'administrateur pour l'informer du dépôt
      dmail = {to:site.mail, fsubject:'[ICARE] Nouvelle inscription', after:start_time}
      inst_mail = mail_should_have_been_sent(dmail)
      # puts "---> mail trouvé : #{inst_mail}"

      # Le mail de confirmation du dépôt de candidature
      dmail = {to:mail, from:site.mail, after:start_time, fsubject:'[ICARE] Confirmation de votre candidature'}
      inst_mail = mail_should_have_been_sent(dmail)

      # Récupération du dernier ticket pour l'user, qui doit exister
      request = "SELECT * FROM icare_hot.tickets WHERE user_id = ? AND created_at > ?"
      ticket = DB.execute(request, [user_id, start_time.to_i]).first
      # puts "--- ticket remonté : #{ticket.inspect}"
      expect(ticket).not_to be_nil
      # Le code du ticket doit être bon
      expect(ticket[:code]).to eq "User::get(#{user_id}).confirm_mail"
      ticket_id = ticket[:id]

      # Un mail a dû être envoyé au candidat pour valider son email
      dmail = {to:mail, from:site.mail, after:start_time, fsubject:'[ICARE] Merci de confirmer votre mail',
        fcontent: [mail, 'Confirmation de votre mail', "href=\"#{site.distant_url}?tckid=#{ticket_id}\""]}
      inst_mail = mail_should_have_been_sent(dmail)
      # puts "---> mail trouvé : #{inst_mail}"

      # L'user repasse par l'accueil pour trouver l'annonce de son inscription
      visit '/'
      expect(page).to have_css('ul#last_actualites li.actu', text: "Inscription de #{pseudo}")
    end
  end
end
