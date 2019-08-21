feature "Identification d'un user" do
  scenario "Un icarien peut s'identifier depuis la page d'accueil", current: true do
    visit '/'
    click_link("S’IDENTIFIER")
    page.save_screenshot("identification.png")
    sleep 2
    expect(page).to have_css('h1', text: 'S’identifier')
    expect(page).not_to have_content("Je ne vous reconnais pas")
  end
end
