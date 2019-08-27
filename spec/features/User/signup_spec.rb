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
# Avant, on prenait le nom, mais ça n'est pas bon car le nom, c'est le numéro
# de session, qui peut être ou non plus grand. Maintenant, il faut dans un
# premier temps mémoriser la liste des dossiers et cette méthode compare cette
# liste avec la liste actuelle et renvoie le dossier qui n'était pas présent
# dans la précédente liste.
def get_last_signup_folder
  if File.exists?('./tmp/signup')
    new_folders = []
    Dir['./tmp/signup/*'].each do |fpath|
      next if prev_signup_folders_list.include?(fpath)
      new_folders << fpath
    end
    # Problème quand il y en a deux
    if new_folders.count > 1
      raise "Problème pour récupérer le dernier dossier candidature créé. Il faut appeler la méthode `memo_current_signup_folders` avant de procéder à un test de création."
    else
      return new_folders.first
    end
  else
    nil
  end
end

def prev_signup_folders_list
  @prev_signup_folders_list
end

def memo_current_signup_folders
  @prev_signup_folders_list = Dir['./tmp/signup/*']
end

feature "Inscription d'un candidat à l'atelier", current: true do
  before(:all) do
    reset_signup_folder
  end
  context 'sans soumettre aucune donnée' do
    scenario 'ne peut pas candidater à Icare' do

      expect {
        visit '/'
        click_link("S’INSCRIRE")
        nombre_inscriptions = signups_count
        expect(page).to have_css('h1', text:'Poser sa candidature')
        expect(page).to have_button('Enregistrer et poursuivre l’inscription')
        click_button('Enregistrer et poursuivre l’inscription')
        screenshot('signup-erreurs')
        # Aucun dossier inscription ne doit avoir été construit
        expect(signups_count).not_to eq(nombre_inscriptions + 1)
      }.not_to change{ TUser.count }

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

      expect do
        visit '/'
        click_link("S’INSCRIRE")
        expect(page).to have_css('h1', text:'Poser sa candidature')
        expect(page).to have_button('Enregistrer et poursuivre l’inscription')
      end.not_to change{TUser.count}

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

  context 'avec un mail invalide' do
    scenario 'ne peut pas s’inscrire' do
      pseudo = "UnBonPseudo"
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('form#form_user_signup')
      [
        'badmail', 'mauvais@mail', '@mauvaismail',
        '!mauvais!@mail.com', 'mauvais@mail.dansuntrucimpossible'
      ].each do |badmail|
        expect do
          within('form#form_user_signup') do
            fill_in('user[pseudo]', with: pseudo)
            fill_in('user[mail]', with: badmail)
            fill_in('user[mail_confirmation]', with: badmail)
            click_button('Enregistrer et poursuivre l’inscription')
          end
        end.not_to change{TUser.count}
        expect(page).to have_css('div#flash div#errors div.error', text: 'Votre mail n\'a pas un bon format de mail')
      end #/boucle sur tous les mauvais mails
    end
  end

  context 'avec un mail mal confirmé' do
    scenario 'ne peut pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('form#form_user_signup')
      expect do
        within('form#form_user_signup') do
          fill_in('user[pseudo]', with: "UnBonPseudo")
          fill_in('user[mail]', with: "Unbonmail@pour.voir")
          fill_in('user[mail_confirmation]', with: "Unebadconf@pour.voir")
          click_button('Enregistrer et poursuivre l’inscription')
        end
      end.not_to change{TUser.count}
      expect(page).to have_css('div#flash div#errors div.error', text: 'La confirmation de votre mail ne correspond pas')
    end
  end

  context 'avec un mauvais mot de passe' do
    scenario 'ne pas pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('form#form_user_signup')

      [
        ' ' => 'Votre code secret est requis',
        'd'*41 => 'Votre code secret ne doit pas excéder les 40 caractères',
        'deavfi' => 'Votre code secret doit faire au moins 8 caractères'
      ].each do |badpass, errmsg|
        expect do
          within('form#form_user_signup') do
            fill_in('user[pseudo]', with: "UnBonPseudo")
            fill_in('user[mail]', with: "Unbonmail@pour.voir")
            fill_in('user[mail_confirmation]', with: "Unbonmail@pour.voir")
            click_button('Enregistrer et poursuivre l’inscription')
          end
        end.not_to change{TUser.count}
        expect(page).to have_css('div#flash div#errors div.error', text: errmsg)
      end #/boucle sur les mots de passe
    end
  end

  context 'avec une confirmation du mot de passe invalide' do
    scenario 'ne peut pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('form#form_user_signup')
      expect do
        within('form#form_user_signup') do
          fill_in('user[pseudo]', with: "UnBonPseudo")
          fill_in('user[mail]', with: "Unbonmail@pour.voir")
          fill_in('user[mail_confirmation]', with: "Unbonmail@pour.voir")
          fill_in('user[password]', with: "UnBonCodeSecret976")
          fill_in('user[password_confirmation]', with: "976")
          click_button('Enregistrer et poursuivre l’inscription')
        end
      end.not_to change{TUser.count}
      expect(page).to have_css('div#flash div#errors div.error', text: 'La confirmation de votre code secret ne correspond pas')
    end
  end

  context 'avec un mauvais captcha' do
    scenario 'ne peut pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('form#form_user_signup')

      xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
      ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
      captcha = xcap + ycap

      [
        ['', 'Le contrôle anti-robot est requis'],
        [captcha+1, 'Le captcha est mauvais']
      ].each do |value, errmsg|
        expect do
          within('form#form_user_signup') do
            fill_in('user[pseudo]', with: "UnBonPseudo")
            fill_in('user[mail]', with: "Unbonmail@pour.voir")
            fill_in('user[mail_confirmation]', with: "Unbonmail@pour.voir")
            fill_in('user[password]', with: "UnBonCodeSecret976")
            fill_in('user[password_confirmation]', with: "UnBonCodeSecret976")
            fill_in('user[captcha]', with: value)
            click_button('Enregistrer et poursuivre l’inscription')
          end
        end.not_to change{TUser.count}
        expect(page).to have_css('div#flash div#errors div.error', text:errmsg)
      end #/liste des captcha erronés
    end
  end

  context 'sans choisir de module d’apprentissage' do
    scenario 'ne peut pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
      expect(page).to have_css('form#form_user_signup')
      xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
      ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
      captcha = xcap + ycap
      now = Time.now.to_i.to_s[-6..-1]
      mail = "mail#{now}@chez.lui"
      pass = "code#{now}"
      udata = {pseudo: "Pseudo#{now}", mail:mail, mail_confirmation:mail,
        password:pass, password_confirmation: pass, captcha: captcha
      }
      expect do
        within('form#form_user_signup') do
          udata.each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).not_to have_css('div#flash div#errors')

        # On doit arriver sur la page du choix du module
        expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        within('form#form_modules') do
          click_button('Enregistrer et poursuivre l’inscription')
        end

        # On doit rester sur la même page, avec un message d'erreur
        expect(page).not_to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).not_to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Il faut optionner au moins un module d’apprentissage")

      end.not_to change{TUser.count}

    end
  end


  context 'sans donner ses documents de présentation' do
    scenario 'on ne peut pas s’inscrire' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
      expect(page).to have_css('form#form_user_signup')
      xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
      ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
      captcha = xcap + ycap
      now = Time.now.to_i.to_s[-6..-1]
      mail = "mail#{now}@chez.lui"
      pass = "code#{now}"
      udata = {pseudo: "Pseudo#{now}", mail:mail, mail_confirmation:mail,
        password:pass, password_confirmation: pass, captcha: captcha
      }
      expect do
        within('form#form_user_signup') do
          udata.each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).not_to have_css('div#flash div#errors')

        # On doit arriver sur la page du choix du module
        expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        within('form#form_modules') do
          check('signup_modules[1]')
          check('signup_modules[7]')
          click_button('Enregistrer et poursuivre l’inscription')
        end

        # On doit rester sur la même page, avec un message d'erreur
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        expect(page).not_to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('div#flash div#errors')

        within('form#form_documents') do
          click_button('Enregistrer la candidature')
        end

        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Vos documents de présentation sont requis")

        presentation_name = 'ma présentation.odt'
        motivation_name   = 'ma motivation.odt'
        presentation_path = File.expand_path(File.join('.','spec','asset','document',presentation_name))
        motivation_path   = File.expand_path(File.join('.','spec','asset','document',motivation_name))

        within('form#form_documents') do
          attach_file('signup_documents[motivation]', motivation_path)
          click_button('Enregistrer la candidature')
        end

        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Votre présentation personnelle est requise")

        within('form#form_documents') do
          attach_file('signup_documents[presentation]', presentation_path)
          click_button('Enregistrer la candidature')
        end

        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Votre lettre de motivation est requise")

      end.not_to change{TUser.count}
    end
  end



  context 'en faisant plusieurs erreurs mais en les corrigeant toutes' do
    scenario 'on peut finaliser l’inscription' do

      # On mémorise les dossiers inscription existants pour pouvoir
      # trouver le nouveau créé par ce test
      memo_current_signup_folders

      start_time = Time.now

      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
      expect(page).to have_css('form#form_user_signup')
      xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
      ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
      captcha = xcap + ycap
      now = Time.now.to_i.to_s[-6..-1]
      mail = "mail#{now}@chez.lui"
      pass = "code#{now}"
      udata = {pseudo: "Pseudo#{now}", mail:mail, mail_confirmation:mail,
        password:pass, password_confirmation: pass, captcha: captcha
      }
      expect do

        def getCaptcha
          xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
          ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
          return xcap + ycap
        end

        # MAUVAISE Soumission (mail existant)
        within('form#form_user_signup') do
          udata.merge(mail:'benoit.ackerman@yahoo.fr', captcha:getCaptcha).each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).to have_css('div#flash div#errors')
        expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})

        # MAUVAISE Soumission (Confirmation mot de passe)
        within('form#form_user_signup') do
          udata.merge(password_confirmation:'', captcha:getCaptcha).each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).to have_css('div#flash div#errors')
        expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})

        # MAUVAISE Soumission (Captcha)
        within('form#form_user_signup') do
          udata.merge(captcha:'').each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).to have_css('div#flash div#errors')
        expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})

        # MAUVAISE Soumission (CGU)
        within('form#form_user_signup') do
          udata.merge(captcha: getCaptcha).each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).to have_css('div#flash div#errors')
        expect(page).to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})

        # La BONNE soumission
        within('form#form_user_signup') do
          udata.merge(captcha: getCaptcha).each do |k, v|
            fill_in("user[#{k}]", with: v)
          end
          check("user[accept_cgu]")
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).not_to have_css('div#flash div#errors')


        # On doit arriver sur la page du choix du module
        # La MAUVAISE soumission
        expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        within('form#form_modules') do
          click_button('Enregistrer et poursuivre l’inscription')
        end
        expect(page).to have_css('div#flash div#errors')
        expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        expect(page).not_to have_css('h2', {text: 'Documents de candidature (3/4)'})

        # La bonne soumission
        within('form#form_modules') do
          check('signup_modules[1]')
          check('signup_modules[7]')
          click_button('Enregistrer et poursuivre l’inscription')
        end

        # On doit rester sur la même page, avec un message d'erreur
        expect(page).not_to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
        expect(page).not_to have_css('h2', {text: 'Informations personnelles (1/4)'})
        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('div#flash div#errors')

        within('form#form_documents') do
          click_button('Enregistrer la candidature')
        end

        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Vos documents de présentation sont requis")

        presentation_name = 'ma présentation.odt'
        motivation_name   = 'ma motivation.odt'
        presentation_path = File.expand_path(File.join('.','spec','asset','document',presentation_name))
        motivation_path   = File.expand_path(File.join('.','spec','asset','document',motivation_name))

        within('form#form_documents') do
          attach_file('signup_documents[motivation]', motivation_path)
          click_button('Enregistrer la candidature')
        end

        expect(page).to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).not_to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).to have_css('div#flash div#errors div.error', text: "Votre présentation personnelle est requise")

        # La bonne soumission
        within('form#form_documents') do
          attach_file('signup_documents[motivation]', motivation_path)
          attach_file('signup_documents[presentation]', presentation_path)
          click_button('Enregistrer la candidature')
        end

        # Pas d'erreur et on est bien sur la page de confirmation
        expect(page).not_to have_css('h2', {text: 'Documents de candidature (3/4)'})
        expect(page).to have_css('h2', {text: 'Confirmation du dépôt (4/4)'})
        expect(page).not_to have_css('div#flash div#errors')

        # Il y a bien un user de plus
      end.to change{TUser.count}

      # Pour être sûr que l'user a bien été créé, on vérifie la présence
      # du watcher de validation qui est la dernière chose créée lors de
      # la création de la candidature

      res = DB.execute("SELECT * FROM icare_users.users WHERE created_at > ?", [start_time.to_i])
      expect(res).not_to be_empty
      duser = res.first
      user_id = duser[:id]
      dwatcher = {user_id:user_id, objet:'user', objet_id:user_id, processus:'valider_inscription'}
      dwatcher = watcher_should_exist(dwatcher)

    end
  end





  context 'avec des données valides' do
    scenario 'peut s’inscrire à l’atelier' do

      # On mémorise les dossiers inscription existants pour pouvoir
      # trouver le nouveau créé par ce test
      memo_current_signup_folders

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
      expect(ddata[:presentation][:fname]).to eq 'Document_presentation.odt'
      expect(ddata[:motivation][:fname]).to eq 'Document_motivation.odt'
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
      ticket = ticket_should_exist({user_id:user_id, after: start_time})
      expect(ticket).not_to be_nil
      # puts "--- ticket remonté : #{ticket.inspect}"
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
