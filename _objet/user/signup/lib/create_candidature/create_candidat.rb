# encoding: UTF-8
=begin

  Extension de la classe User pour créer l'utilisateur après son inscription
  valide.

=end
class User
  class << self

    def this_folder
      @this_folder ||= SuperFile.new(File.dirname(__FILE__))
    end

    attr_reader :new_user

    # Méthode appelée à la fin de l'inscription, pour créer
    # l'user dans la base de données
    #
    # RETURN True si tout s'est bien passé, false dans le cas contraire
    #
    def create_candidature
      app.benchmark('-> User::create_candidature')

      # Bloque le rechargement intempestif de la page
      app.checkform_on_submit

      # [[Pourquoi doit-on mettre les données d'identité là-dedans]]
      param(data_identite: Signup.get_identite)

      # Toutes les données récoltées au cours des trois étapes
      # doivent être valides
      all_data_valides? || return

      @new_user = newuser = User.new
      newuser.create || raise("Impossible de créer la nouvelle candidature…")
      # Dans les versions précédentes, on identifiait (login) le candidat
      # Maintenant, il faudra qu'il valide son mail pour être identifié.
      # Cela permet aussi de ne pas avoir à gérer les redirections et de
      # bien arriver sur la page de confirmation de la candidature.

      Signup.new_user= newuser # pour les vues

      # On crée une annonce pour la page d'accueil
      annonce_nouvelle_inscription

      # On crée un watcher qui permettra à l'administrateur de valider
      # ou refuser la candidature
      create_watcher_validation_candidature

      app.benchmark('<- User::create_new_user')
      return true
    end

    # On s'assure que toutes les données des trois étapes soient valides
    def all_data_valides?
      @data_identite = Signup.get_identite
      @data_identite || raise('Impossible de trouver les données d’identité. Je ne peux pas créer votre candidature.')
      @data_modules = Signup.get_modules
      @data_modules  || raise('Impossible de trouver les données de modules. Je ne peux pas créer votre candidature.')
      @data_documents = Signup.get_documents
      @data_documents || raise('Impossible de trouver la données des documents. Je ne peux pas créer votre candidature.')
      @data_documents.each do |doc_id, doc_name|
        doc_name != nil || next
        doc_path = Signup.path_tmp_document(doc_name)
        doc_path.exist? || raise("Le document `#{doc_name}` est introuvable… Je ne peux pas enregistrer votre candidature.")
      end
    rescue Exception => e
      debug e
      error e.message
    else
      true
    end

    def annonce_nouvelle_inscription
      # On fait l'annonce de cette nouvelle inscription (noter)
      # qu'elle est faite avant d'avoir pris les documents et
      # les modules choisis
      site.require_objet 'actualite'
      SiteHtml::Actualite.create(:signup)
    end

    # Watcher qui permettra à l'administrateur de valider ou de refuser
    # la candidature et au candidat de voir l'état de sa candidature sur
    # son bureau
    def create_watcher_validation_candidature
      new_user.add_watcher(
        objet:      'user',
        objet_id:   new_user.id,
        processus:  'valider_inscription',
        data:       app.session.session_id
      )
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
    debug "[User#create] Sauvegarde des données OK"
    self.send_mail_confirmation_mail  || return
    debug "[User#create] Envoi du mail de confirmation OK"
    self.send_mail_bienvenue          || return
    debug "[User#create] Envoi du mail de bienvenue OK"
    self.send_mail_annonce_admin      || return
    debug "[User#create] Envoi du mail d'annonce à l'administrateur OK"

    app.benchmark('<- User#create')

    return true
  end

  def this_folder
    @this_folder ||= self.class.this_folder
  end


  # On envoie à l'utilisateur un message pour qu'il confirme
  # son adresse-mail.
  def send_mail_confirmation_mail
    send_mail(
      subject: 'Merci de confirmer votre mail',
      message: (this_folder+'mail_confirmation.erb').deserb(self),
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
    self.send_mail(
      subject:    'Bienvenue !',
      message:    (this_folder+'mail_bienvenue.erb').deserb(self),
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
    send_mail_to_admin(
      subject:  'Nouvelle inscription',
      message:  (this_folder+'mail_admin.erb').deserb(self),
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
    debug "[User#save_all_data] @id = #{@id.inspect}"
    return @id
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

    debug "[User#data2save_ok?] data_identite: #{du.inspect}"

    du[:mail] = du[:mail].nil_if_empty
    raise('Le mail ne devrait pas être nil…') if du[:mail].nil?

    du[:pseudo] = du[:pseudo].nil_if_empty
    raise('Le pseudo ne devrait pas être nil…') if du[:pseudo].nil?

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
