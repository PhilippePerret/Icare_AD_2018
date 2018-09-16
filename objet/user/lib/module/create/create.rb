# encoding: UTF-8
=begin

  Extension de la classe User pour créer l'utilisateur après son inscription
  valide.

=end
class User
  class << self

    attr_reader :new_user

    # Méthode appelée à la fin de l'inscription, pour créer
    # l'user dans la base de données
    #
    # RETURN True si tout s'est bien passé, false dans le cas contraire
    #
    def create_new_user
      app.benchmark('-> User::create_new_user')
      @new_user = newuser = User.new
      if newuser.create
        # On login l'user provisoirement, mais il faudra qu'il
        # confirme son adresse mail à la session suivante
        newuser.login
        # On fait l'annonce de cette nouvelle inscription (noter)
        # qu'elle est faite avant d'avoir pris les documents et
        # les modules choisis
        site.require_objet 'actualite'
        SiteHtml::Actualite.create(:signup)
        return true
      else
        return false
      end
      app.benchmark('<- User::create_new_user')
    end
  end # << self

  # ---------------------------------------------------------------------
  #   Instance User
  # ---------------------------------------------------------------------

  attr_reader :cpassword, :random_salt

  # Création de l'user et envoi des mails d'annonce
  def create
    app.benchmark('-> User#create')
    # Les données ont déjà été checkées, il suffit de créer un salt et
    # le mot de passe crypté.

    save_all_data                     || return
    self.send_mail_confirmation_mail  || return
    self.send_mail_bienvenue          || return
    self.send_mail_annonce_admin      || return

    app.benchmark('<- User#create')
  end


  # On envoie à l'utilisateur un message pour qu'il confirme
  # son adresse-mail.
  def send_mail_confirmation_mail
    pmail = User.folder_modules + 'create/mail_confirmation.erb'
    send_mail(
      subject: 'Merci de confirmer votre mail',
      message: pmail.deserb(self),
      formated: true
    )
  rescue Exception => e
    debug "### PROBLÈME À L'ENVOI DU MAIL DE CONFIRMATION"
    debug e
    error e.message
  else
    true
  end

  # On envoie un mail à l'utilisateur pour confirmer son
  # inscription.
  def send_mail_bienvenue
    pmail = User.folder_modules + 'create/mail_bienvenue.erb'
    self.send_mail(
      subject:    'Bienvenue !',
      message:    pmail.deserb(self),
      formated:   true
    )
  rescue Exception => e
    debug "### PROBLÈME À L'ENVOI DU MAIL DE BIENVENUE"
    debug e
    error e.message
  else
    true
  end

  # On envoie un mail à l'administration pour informer
  # de l'inscription
  def send_mail_annonce_admin
    pmail = User.folder_modules + 'create/mail_admin.erb'
    send_mail_to_admin(
      subject:  'Nouvelle inscription',
      message:  pmail.deserb(self),
      formated: true
    )
  rescue Exception => e
    debug "### PROBLÈME À L'ENVOI DU MAIL D'ANNONCE DE NOUVELLE INSCRIPTION"
    debug e
  end

  # Méthode qui sauve toutes les données de l'user d'un coup
  # Note : pour le moment, on n'utilise cette méthode que dans
  # ce module consacré à la création.
  # Cela renvoie l'ID, en tout cas si tout a bien fonctionné.
  def save_all_data
    data2save_ok? || (return false)
    @id = dbtable_users.insert(data2save)
  end

  # Les données inégrales à sauver
  def data2save
    now = Time.now.to_i
    @duser = param(:data_identite)

    # On calcule le sel et le mot de passe crypté
    calc_random_salt
    calc_cpassword @duser[:password], @duser[:mail], random_salt

    # debug "Mot de passe crypté calculé avec :"
    # debug "PWD: #{@duser[:password].inspect}"
    # debug "MEL: #{@duser[:mail].inspect}"
    # debug "SEL: #{random_salt.inspect}"

    # Les propriétés à supprimer
    [:mail_confirmation, :password, :password_confirmation].each do |prop|
      @duser.delete(prop)
    end

    @duser.merge!(
      pseudo:       real_pseudo,
      cpassword:    cpassword,
      salt:         random_salt,
      created_at:   now,
      updated_at:   now
    )

    return @duser
  end

  def data2save_ok?
    du = param(:data_identite)

    du[:mail] = du[:mail].nil_if_empty
    du[:mail] != nil || raise('Le mail ne devrait pas être nil…')

    du[:pseudo] = du[:pseudo].nil_if_empty
    du[:pseudo] != nil || raise('Le pseudo ne devrait pas être nil…')

    [:patronyme, :telephone, :adresse].each do |prop|
      du[prop] = du[prop].nil_if_empty
    end

    ['F','H'].include?(du[:sexe]) || raise('Le sexe devrait être défini…')

    param(data_identite: du)
  rescue Exception => e
    error e
  else
    true
  end

  # Retourne le pseudo avec toujours la première
  # lettre capitalisée (mais on ne touche pas aux autres)
  def real_pseudo
    pse = @duser[:pseudo]
    pse[0].upcase + pse[1..-1]
  end


  # Retourne le mot de passe crypté
  def calc_cpassword pwd, mel, salt
    require 'digest/md5'
    @cpassword = Digest::MD5.hexdigest("#{pwd}#{mel}#{salt}")
  end

  # Retourne un nouveau sel pour le mot de passe crypté
  # C'est un mot de 10 lettres minuscules choisies au hasard
  def calc_random_salt
    @random_salt = 10.times.collect{ |itime| (rand(26) + 97).chr }.join('')
  end

end
