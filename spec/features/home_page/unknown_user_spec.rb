
feature "La page d'accueil de l'atelier", type: :feature do
  before(:each) do
    visit '/'
  end

  scenario 'contient toutes les sections attendues' do
    expect(page).to have_css('section#header_home')
    expect(page).to have_css('section#main-logo-in-first-page')
    expect(page).to have_css('div#presentation-atelier')
    expect(page).to have_css('div#presentation_phil')
    expect(page).to have_css('div#bloc-citation')
    expect(page).to have_css('div#faq')
    expect(page).to have_css('div#div_last_actualites')
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

  scenario 'permet de rejoindre toutes les parties liées' do
    {
      "EN SAVOIR PLUS"  => "Présentation d’Icare",
      "PRÉSENTATION COMPLÈTE" => "Présentation d’Icare",
      "S’INSCRIRE"      => "Poser sa candidature",
      "S’IDENTIFIER"    => "S’identifier",
      "RÉUSSITES"       => ["Présentation d’Icare", "Hall of Fame"]
    }.each do |link_name, page_title|
      expect(page).to have_link(link_name)
      click_link(link_name)
      if page_title.is_a?(Array)
        page_title, page_subtitle = page_title
      end
      expect(page).to have_css('h1', text:page_title)
      if page_subtitle
        expect(page).to have_css('h2', text:page_subtitle)
      end
      click_link("Accueil")
    end
  end
end
