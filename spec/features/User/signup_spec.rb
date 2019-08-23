# encoding: UTF-8
=begin
Test de l'inscription d'un candidat
=end

feature "Inscription d'un candidat à l'atelier" do
  context 'sans soumettre aucune donnée', current: true do
    scenario 'ne peut pas candidater à Icare' do
      visit '/'
      click_link("S’INSCRIRE")
      expect(page).to have_css('h1', text:'Poser sa candidature')
      expect(page).to have_button('Enregistrer et poursuivre l’inscription')
      click_button('Enregistrer et poursuivre l’inscription')
      screenshot('signup-erreurs')
      # Il doit y avoir des erreurs
      expect(page).to have_css('div#flash div#errors div.error')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Un pseudo est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Votre mail est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Votre code secret est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Le contrôle anti-robot est requis')
      expect(page).to have_css('div#flash div#errors div.error', text: 'Vous devez accepter les Conditions Générales d’Utilisation')
    end
  end

  context 'avec des données invalides' do
    scenario 'ne peut pas s’inscrire à l’atelier' do

    end
  end
  context 'avec des données valides' do
    scenario 'peut s’inscrire à l’atelier' do

    end
  end
end
