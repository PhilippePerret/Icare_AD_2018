# encoding: UTF-8
module Features
  module SessionHelpers

    def identify_benoit
      require './data/secret/data_benoit'
      click_link("S’IDENTIFIER")
      within('form#form_user_login') do
        fill_in 'login[mail]', with: DATA_BENOIT[:mail]
        fill_in 'login[password]', with: DATA_BENOIT[:password]
        click_button('OK')
      end
      expect(page).to have_content("Bienvenue, BenoA !")
      # expect(page).to have_content("Bienvenue, BenoA !", count: 1)
      # TODO Pour le moment on se contente d'avoir le message, mais plus tard, on doit vérifier
      # qu'il n'apparaisse qu'une seule fois.
    end

end
end
