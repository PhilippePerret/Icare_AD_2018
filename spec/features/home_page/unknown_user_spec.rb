
feature "La page d'accueil de l'atelier", type: :feature do
  before(:each) do
    visit '/'
  end
  scenario 'contient les textes attendus' do
    expect(page).to have_content("Atelier Icare")
    expect(page).to have_content("un atelier d’écriture en ligne")
    expect(page).to have_content("PHILIPPE PERRET")
  end

  scenario 'contient les liens utiles' do
    ["EN SAVOIR PLUS", "S’INSCRIRE", "S’IDENTIFIER", "mort@vivant","Savoir rédiger et présenter son scénario","RÉUSSITES","ICARIEN(NE)S","TÉMOIGNAGES"].each do |link|
      expect(page).to have_content(link)
    end
  end

  scenario 'permet de rejoindre les parties escomptées' do
    click_link("EN SAVOIR PLUS")
    expect(page).to have_title("Présentation d’Icare")
    click_link("Accueil")
    expect(page).to have_link("S’INSCRIRE")
    click_link("S’INSCRIRE")
    expect(page).to have_title("Poser sa candidature")
  end
end
