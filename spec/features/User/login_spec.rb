require './data/secret/data_benoit' # => DATA_BENOIT

def benoit
  @benoit ||= User.get(84)
end
feature "Identification d'un user" do

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
      expect(page).to have_content('Bienvenue, BenoA !', count: 1)
    end

    scenario 'l’icarien est redirigé vers la page voulue dans ses préférences', current: true do
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
        benoit.set_option(18, value)
      end

      set_redir_ben(0) # => accueil
      login_ben
      expect(page).to be_home_page
      logout_ben

      set_redir_ben(1) # => bureau
      login_ben
      expect(page).to have_css('h1', text: 'Votre bureau')
      logout_ben


    end
  end
end
