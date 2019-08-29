# encoding: UTF-8
module Features
  module SessionHelpers

    def identify_phil
      require './data/secret/data_phil'
      identify_user(mail: DATA_PHIL[:mail], password: DATA_PHIL[:password])
    end

    def identify_benoit
      require './data/secret/data_benoit'
      identify_user(mail: DATA_BENOIT[:mail], password: DATA_BENOIT[:password])
    end

    def identify_user params
      if params.is_a?(Integer)
        params = DB.getOne('icare_users.users', params)
      end
      click_link("S’IDENTIFIER")
      within('form#form_user_login') do
        fill_in 'login[mail]', with: params[:mail]
        fill_in 'login[password]', with: params[:password]
        click_button('OK')
      end
      expect(page).to have_content("Bienvenue, BenoA !")
    end

end
end
