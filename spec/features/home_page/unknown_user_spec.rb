feature "Page d'accueil de l'atelier" do
  scenario 'est correct' do
    visit '/'
    expect(page).to have_content("Atelier Icare")
  end
end
