# encoding: UTF-8
class Signup
class << self

  def form_data
    @form_data ||= param(:user)
  end

  def form_error msg
    @form_errors << msg
  end

  # Retourne true si les données d'identité sont valides
  def data_valides?
    app.benchmark('-> User#data_valides?')

    @form_errors = []

    # debug "form_data = #{form_data.pretty_inspect}"

    # Validité du PSEUDO
    check_pseudo

    # Validité du patronyme
    check_patronyme

    # Validité du mail
    check_mail

    # Validité du mot de passe
    check_password

    # On variabilise les choses non testées
    check_sexe

    check_captcha

    # Les CGU doivent avoir été acceptées
    check_cgu_acceptation

    @naissance  = form_data[:naissance].to_i

    check_phone_number

    @adresse    = form_data[:adresse].nil_if_empty

    unless @form_errors.empty?
      errs_count = @form_errors.count
      error "#{errs_count} erreur#{errs_count>1 ? 's' : ''} empêchent votre candidature, merci de les corriger :"
      errors_as_list(@form_errors)
      return false
    end

  rescue Exception => e
    # debug e
    error e.message
  else
    true
  ensure
    app.benchmark('<- User#data_valides?')
  end

  def check_pseudo
    @pseudo = form_data[:pseudo].nil_if_empty
    raise( "Un pseudo est requis." ) if @pseudo.nil?
    ! pseudo_exist?(@pseudo) || raise("Ce pseudo est déjà utilisé, merci d'en choisir un autre")
    @pseudo.length < 40 || raise("Ce pseudo est trop long. Il doit faire moins de 40 caractères.")
    @pseudo.length >= 3 || raise("Ce pseudo est trop court. Il doit faire au moins 3 caractères.")

    reste = @pseudo.gsub(/[a-zA-Z0-9_\-]/,'')
    reste == "" || raise("Ce pseudo est invalide. Il ne doit comporter que lettres, chiffres, traits plats et tirets. Il comporte les caractères interdits : #{reste.split.pretty_join}")
  rescue Exception => e
    form_error e.message
  end

  # Return true si le pseudo existe déjà
  def pseudo_exist?(pseudo)
    return dbtable_users.count(where: "pseudo = '#{@pseudo}'") > 0
  end

  def check_patronyme
    @patronyme = form_data[:patronyme].nil_if_empty
    if site.signup_patronyme_required || !@patronyme.nil?
      raise "Il faut fournir le patronyme." if @patronyme.nil?
      raise "Le patronyme ne doit pas faire plus de 255 caractères." if @patronyme.length > 255
      raise "Le patronyme ne doit pas faire moins de 3 caractères." if @patronyme.length < 3
    else
      # La table a toujours besoin du patronyme
      @patronyme ||= @pseudo
    end
  rescue Exception => e
    form_error e.message
  end

  def check_mail
    @mail = form_data[:mail].nil_if_empty
    raise "Votre mail est requis." if @mail.nil?
    raise "Votre mail est trop long." if @mail.length > 255
    raise "Votre mail n'a pas un bon format de mail." if @mail.gsub(/^[a-zA-Z0-9_\.\-]+@[a-zA-Z0-9_\.\-]+\.[a-zA-Z0-9_\.\-]{1,6}$/,'') != ""
    raise "Votre mail existe déjà… Vous devez déjà être inscrit…" if mail_exist?( @mail )
    raise "La confirmation de votre mail ne correspond pas." if @mail != form_data[:mail_confirmation]
  rescue Exception => e
    form_error e.message
  end

  # Return True si le mail +mail+ se trouve déjà dans la table
  def mail_exist?(mail)
    return dbtable_users.count(where: "mail = '#{@mail}'") > 0
  end

  def check_password
    @password = form_data[:password].nil_if_empty
    raise "Votre code secret est requis." if @password.nil?
    raise "Votre code secret ne doit pas excéder les 40 caractères." if @password.length > 40
    raise "Votre code secret doit faire au moins 8 caractères." if @password.length < 8
    raise "La confirmation de votre code secret ne correspond pas." if @password != form_data[:password_confirmation]
  rescue Exception => e
    form_error e.message
  end

  def check_sexe
    @sexe = form_data[:sexe].nil_if_empty
    raise "Le sexe devrait être défini." if @sexe.nil?
    raise "Le sexe n'a pas la bonne valeur." unless ['F', 'H'].include?(@sexe)
  rescue Exception => e
    form_error e.message
  end

  def check_captcha
    captcha = form_data[:captcha].nil_if_empty
    raise('Le contrôle anti-robot est requis.') if captcha.nil?
    raise('Le captcha est mauvais, seriez-vous un robot ?') unless app.captcha_valid?(captcha)
  rescue Exception => e
    form_error e.message
  end

  def check_cgu_acceptation
    unless form_data[:accept_cgu] == 'ok'
      raise("Vous devez accepter les Conditions Générales d’Utilisation (en cochant la case au-dessus du bouton de soumission).")
    end
  rescue Exception => e
    form_error e.message
  end

  def check_phone_number
    @phone      = form_data[:telephone].nil_if_empty
    @phone.nil? || @phone.length < 11 || raise('Votre numéro de téléphone est invalide.')
  rescue Exception => e
    form_error e.message
  end

end #/<< self
end #/ Signup
