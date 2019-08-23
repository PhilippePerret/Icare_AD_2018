# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_identite
    data_valides? || (return false)
    # On enregistre les données dans le fichier marshal
    marshal_file('identite').write Marshal.dump(data2save)
  end

  # Méthode qui récupère les données de l'identité dans le
  # fichier Marshal et les renvoie.
  # Cette méthode appelée chaque fois que la page de l'identité
  # est appelée.
  # Return NIL si le fichier n'existe pas encore
  def get_identite
    marshal_file('identite').exist? || (return nil)
    Marshal.load(marshal_file('identite').read)
  end

  def data2save
    now = Time.now.to_i
    {
      pseudo:       @pseudo,
      patronyme:    @patronyme,
      sexe:         @sexe,
      naissance:    @naissance,
      mail:         @mail,
      mail_confirmation: @mail,
      password:     @password,
      password_confirmation: @password,
      telephone:    @phone,
      adresse:      @adresse,
      session_id:   app.session.session_id,
      options:      '0'*10,
      created_at:   now,
      updated_at:   now
    }
  end

  # Retourne true si les données d'identité sont valides
  def data_valides?
    app.benchmark('-> User#data_valides?')

    form_data = param(:user)

    # Les CGU doivent avoir été acceptées
    unless form_data[:accept_cgu] == 'on'
      raise("Vous devez accepter les Conditions Générales d'Utilisation (en cochant la case au-dessus du bouton de soumission).")
    end

    # Validité du PSEUDO
    @pseudo = form_data[:pseudo].nil_if_empty
    ! @pseudo.nil? || raise( "Il faut fournir le pseudo." )
    ! pseudo_exist?(@pseudo) || raise("Ce pseudo est déjà utilisé, merci d'en choisir un autre")
    @pseudo.length < 40 || raise("Le pseudo doit faire moins de 40 caractères.")
    @pseudo.length >= 3 || raise("Le pseudo doit faire au moins 3 caractères.")

    reste = @pseudo.gsub(/[a-zA-Z_\-]/,'')
    reste == "" || raise("Le pseudo ne doit comporter que des lettres, traits plats et tirets. Il comporte les caractères interdits : #{reste.split.pretty_join}")
    # Validité du patronyme
    @patronyme = form_data[:patronyme].nil_if_empty
    if site.signup_patronyme_required || !@patronyme.nil?
      raise "Il faut fournir le patronyme." if @patronyme.nil?
      raise "Le patronyme ne doit pas faire plus de 255 caractères." if @patronyme.length > 255
      raise "Le patronyme ne doit pas faire moins de 3 caractères." if @patronyme.length < 3
    else
      # La table a toujours besoin du patronyme
      @patronyme ||= @pseudo
    end

    # Validité du mail
    @mail = form_data[:mail].nil_if_empty
    raise "Il faut fournir votre mail." if @mail.nil?
    raise "Ce mail est trop long." if @mail.length > 255
    raise "Ce mail n'a pas un bon format de mail." if @mail.gsub(/^[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}$/,'') != ""
    raise "Ce mail existe déjà… Vous devez déjà être inscrit…" if mail_exist?( @mail )
    raise "La confirmation du mail ne correspond pas." if @mail != form_data[:mail_confirmation]

    # Validité du mot de passe
    @password = form_data[:password].nil_if_empty
    raise "Il faut fournir un mot de passe." if @password.nil?
    raise "Le mot de passe ne doit pas excéder les 40 caractères." if @password.length > 40
    raise "Le mot de passe doit faire au moins 8 caractères." if @password.length < 8
    raise "La confirmation du mot de passe ne correspond pas." if @password != form_data[:password_confirmation]

    # On variabilise les choses non testées
    @sexe = form_data[:sexe].nil_if_empty
    raise "Le sexe devrait être défini." if @sexe.nil?
    raise "Le sexe n'a pas la bonne valeur." unless ['F', 'H'].include?(@sexe)

    if site.captcha_value
      captcha = form_data[:captcha].nil_if_empty
      captcha != nil || raise('Il faut fournir le captcha pour nous assurer que vous n’êtes pas un robot.')
      app.captcha_valid?(captcha) || raise('Le captcha est mauvais, seriez-vous un robot ?')
    end
    
    @naissance  = form_data[:naissance].to_i
    @phone      = form_data[:telephone].nil_if_empty
    @phone.nil? || @phone.length < 11 || raise('Votre numéro de téléphone n’est pas correct…')
    @adresse    = form_data[:adresse].nil_if_empty

  rescue Exception => e
    # debug e
    error e.message
  else
    true
  ensure
    app.benchmark('<- User#data_valides?')
  end


  # Return true si le pseudo existe
  def pseudo_exist?(pseudo)
    return dbtable_users.count(where: "pseudo = '#{@pseudo}'") > 0
  end

  # Return True si le mail +mail+ se trouve déjà dans la table
  def mail_exist?(mail)
    return dbtable_users.count(where: "mail = '#{@mail}'") > 0
  end

end #/<< self
end #/ Signup
