require './data/secret/data_benoit' # => DATA_BENOIT

def benoit
  @benoit ||= User.get(84)
end

feature "Identification d'un user" do

  after(:all) do
    # À la fin des tests, il faut remettre le bit de redirection de benoit pour
    # qu'il se dirige vers la page d'accueil après sa connexion au site.
    # Note : c'est le premier 4.
    db_execute("UPDATE icare_users.users SET options = \"001000000000000040400008\" WHERE id = 84;")
  end

  context 'avec des identificateus incorrects' do

    scenario 'l’user ne peut pas s’identifier' do
      visit '/'
      click_link("S’IDENTIFIER")
      [
        ["badmailbadpawd@chez.com", "bad password"],
        [DATA_BENOIT[:mail], "mauvais password"],
        ["badmailgoodpwd@chez.com", DATA_BENOIT[:password]]
      ].each do |paire|
        mail, password = paire
        within('form#form_user_login') do
          fill_in 'login[mail]', with: mail
          fill_in 'login[password]', with: password
          click_button( 'OK' )
        end
        expect(page).not_to have_content('Bienvenue')
        expect(page).to have_content("Je ne vous reconnais pas")
      end
    end
  end
  context 'avec des identificateurs corrects' do
    after(:each) do
      logout_ben
    end

    scenario "Un icarien peut s'identifier depuis la page d'accueil" do
      visit '/'
      click_link("S’IDENTIFIER")
      screenshot('identification')
      expect(page).to have_css('h1', text: 'S’identifier')
      expect(page).not_to have_content("Je ne vous reconnais pas")
      within('form#form_user_login') do
        fill_in 'login[mail]', with: DATA_BENOIT[:mail]
        fill_in 'login[password]', with: DATA_BENOIT[:password]
        click_button( 'OK' )
      end
      expect(page).to have_content('Bienvenue BenoA !', count: 1)
    end

    def login_ben
      visit '/'
      click_link('S’IDENTIFIER')
      within('form#form_user_login') do
        fill_in 'login[mail]', with: DATA_BENOIT[:mail]
        fill_in 'login[password]', with: DATA_BENOIT[:password]
        click_button( 'OK' )
      end
    end
    def logout_ben
      click_link('SE DÉCONNECTER')
    end
    def set_redir_ben value
      db_execute("UPDATE icare_users.users SET options = \"001000000000000040#{value}00008\" WHERE id = 84;")
    end

    context 'sans choix de redirection' do
      scenario 'l’icarien est redirigé vers la page "sans redirection"' do
        set_redir_ben(0) # => Pas de redirection définie
        login_ben
        screenshot('after-identify-0')
        expect(page).to have_css('h1', text: 'Bienvenue BenoA !')
      end
    end
    context 'avec un choix de redirection vers le bureau' do
      scenario 'l’icarien est redirigé vers son bureau' do

        set_redir_ben(1) # => bureau
        login_ben
        screenshot('after-identify-1')
        expect(page).to have_css('h1', text: 'Votre bureau')

        # set_redir_ben(4) # => accueil
        # screenshot('after-identify-4')
        # login_ben
        # expect(page).to be_home_page
      end
    end

    context 'avec un choix de redirection vers le profil' do
      scenario 'l’icarien est redirigé vers son profil' do
        set_redir_ben(2) # => profil
        login_ben
        screenshot('after-identify-2')
        expect(page).to have_css('h1', text: 'Votre profil')
      end
    end

    context 'avec un choix de redirection vers la dernière page consultée' do
      scenario 'l’icarien est redirigé vers sa dernière page' do
        set_redir_ben(3) # => dernière page
        # On définit la dernière page de ben
        db_execute("UPDATE icare_hot.connexions SET route = 'overview/reussites' WHERE id = 84;")
        login_ben
        screenshot('after-identify-3')
        expect(page).to have_css('h1', text: 'Présentation d’Icare')
        expect(page).to have_css('h2', text: 'Hall of Fame')
      end
    end
  end
end
