# encoding: UTF-8

=begin
  Méthode qui crée une candidature (en le faisant de façon interactive)

  @return user_id Identifiant du nouvel user créé

  data = {
    with_extrait:     Si true, on joint un document avec extraits
    mail_confirmed:   Si true (défaut) le mail sera confirmé tout de suite
  }
=end
def create_candidature data = nil
  data ||= {}

  # Valeurs par défaut
  data.key?(:mail_confirmed) || data.merge!(mail_confirmed: true)

  start_time = Time.now

  now = Time.now.to_i.to_s[-6..-1]
  pseudo  = "Icarien#{now}"
  mail    = "mail#{now}@chez.lui"
  pass    = "#{now}#{now}"
  dataSignup = {
    pseudo: pseudo, mail:mail, mail_confirmation:mail,
    password:pass, password_confirmation:pass,
    naissance: rand(1960..2000),
    accept_cgu: true
  }
  dataSignup.merge!(data) unless data.empty?

  visit '/'
  click_link("S’INSCRIRE")

  xcap = page.execute_script("return document.querySelector('span#xcap').innerHTML").to_i
  ycap = page.execute_script("return document.querySelector('span#ycap').innerHTML").to_i
  dataSignup.merge!(captcha: xcap + ycap)

  within('form#form_user_signup') do
    dataSignup.each do |prop, value|
      case prop
      when :mail_confirmed
        # rien à faire
        next
      when :naissance
        select(value, from: 'user[naissance]')
      when :accept_cgu
        value ? check('user[accept_cgu]') : uncheck('user[accept_cgu]')
      else
        fill_in("user[#{prop}]", with: value)
      end
    end
    click_button('Enregistrer et poursuivre l’inscription')
  end
  # Aucune erreur ne doit avoir été produite
  expect(page).not_to have_css('div#flash div#errors')

  # ---- Choix du module d'apprentissage

  expect(page).to have_css('h2', {text: 'Modules d’apprentissage optionnés (2/4)'})
  data.key?(:modules) || data.merge!(modules: [2,4])
  within('form#form_modules') do
    data[:modules].each do |module_id|
      check("signup_modules[#{module_id}]") # Documents
    end
    click_button('Enregistrer et poursuivre l’inscription')
  end
  # Pas d'erreur
  expect(page).not_to have_css('div#flash div#errors')


  # --- Documents de présentation ---
  expect(page).to have_css('h2', text: 'Documents de candidature (3/4)')
  presentation_name = 'ma présentation.odt'
  motivation_name   = 'ma motivation.odt'
  extrait_name      = 'mon extrait.odt'
  presentation_path = File.expand_path(File.join('.','spec','asset','document',presentation_name))
  motivation_path   = File.expand_path(File.join('.','spec','asset','document',motivation_name))
  extrait_path      = File.expand_path(File.join('.','spec','asset','document',extrait_name))
  within('form#form_documents') do
    attach_file('signup_documents[presentation]', presentation_path)
    attach_file('signup_documents[motivation]',   motivation_path)
    attach_file('signup_documents[extraits]',     extrait_path) if data[:with_extrait]
    click_button('Enregistrer la candidature')
  end
  # Aucune erreur
  expect(page).not_to have_css('div#flash div#errors')


  # ---- Page de confirmation ----

  expect(page).to have_css('h2', text: 'Confirmation du dépôt (4/4)')
  res = DB.execute("SELECT * FROM icare_users.users WHERE created_at > ?", [start_time.to_i])
  expect(res).not_to be_empty
  duser = res.first
  user_id = duser[:id]

  # Récupération du dernier ticket pour confirmer l'email
  ticket = ticket_should_exist({user_id:user_id, after: start_time})
  ticket_id = ticket[:id]

  # L'user confirme son email
  if data[:mail_confirmed]
    visit ("/?tckid=#{ticket_id}")
    expect(page).to have_message("votre mail est confirmé")
  end

  return user_id
end
