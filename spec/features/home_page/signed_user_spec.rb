feature "La page d'accueil" do
  context 'pour un icarien identifié' do
    before(:each) do
      # TODO Il faut s'assurer que Benoit ait réglé ses options pour
      # rester sur la page d'accueil lorsqu'il s'est loggué.
      visit('/')
      identify_benoit
    end
    scenario 'contient des liens valides pour rejoindre le profil, le bureau' do
      {
        "VOTRE PROFIL" => ["Votre profil"],
        "VOTRE BUREAU" => ["Votre bureau"]
      }.each do |link_name, title_page|
        expect(page).to have_link(link_name)
        click_link(link_name)
        expect(page).to have_css('h1', text: title_page.first)
        click_link("Atelier Icare")
      end

    end
    scenario 'contient un lien valide pour se déconnecter' do
      expect(page).to have_link("SE DÉCONNECTER")
      click_link("SE DÉCONNECTER")
      expect(page).not_to have_link("SE DÉCONNECTER")
      expect(page).to have_link("S’IDENTIFIER")
    end
    scenario 'ne contient plus les liens pour s’identifier, s’inscrire ou en savoir plus' do
      ["EN SAVOIR PLUS", "S’INSCRIRE", "S’IDENTIFIER"].each do |link|
        expect(page).not_to have_link(link)
      end
    end
  end
end
