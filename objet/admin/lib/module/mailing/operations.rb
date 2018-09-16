# encoding: UTF-8
class Admin
class Mailing
class << self


  # Sujet du mail
  attr_reader   :subject
  # Message du mail
  attr_reader   :message

  # Le message complet, en template
  # (cf. méthode)
  # attr_reader   :template_formated

  # Clés des destinataires requis
  # parmi : KEYS_DESTINATAIRES
  attr_reader :keys_destinataires

  # Liste des données mini des destinataires
  # (cf. méthode)
  # attr_reader :destinataires

  # Options
  attr_reader :options

  def admin
    @admin ||= User.new(1)
  end

  # = main =
  #
  # Traite l'opération demandée (param :operation)
  #
  def exec_operation
    define_init_options
    unless param(:operation).nil?
      method = "exec_#{param(:operation)}".to_sym
      if self.respond_to? method
        self.send method
      else
        error "La méthode Admin::Mailing.#{method} est inconnue."
      end
    end
  end

  # ---------------------------------------------------------------------
  #
  #   OPÉRATIONS
  #
  # ---------------------------------------------------------------------

  #
  #
  # Préparation du mail et des destinataires
  #
  # La méthode est appelée quand on clique sur le bouton
  # “Prépare le mailing” dans le formulaire de rédaction du mail à
  # envoyer.
  # Elle récupère les icariens en fonction des options, traite le
  # message et prépare :content pour afficher le mail à valider avant
  # de l'envoyer.
  #
  def exec_prepare_mailing
    define_params_and_check_values_or_raise
    # debug "Données pour le mailing : " + {
    #   subject: subject, message: message,
    #   keys_destinataires: keys_destinataires,
    #   options: options
    # }.inspect

    c = ""

    #
    # Présentation d'un message formaté
    #
    c << "Le message formaté ressemblera à :".in_div(class: 'titre')
    sujet = "Sujet : <strong>#{subject}</strong>".in_div
    c << (sujet + first_message).in_div(id: 'first_message_formated', class: 'cadre')

    #
    # Présentation de la liste des destinataires
    #
    c << "Destinataires".in_div(class: 'titre')
    hdest =
      if destinataires.count > 0
        destinataires.collect{|u| "#{u.pseudo} - #{u.mail}" }.join("<br />")
      else
        'Attention ! Aucun destinataire n’a été trouvé !'.in_span(class: 'warning bold')
      end
    c << hdest.in_div(id: 'destinataires_list', class: 'cadre')

    #
    # Présentation des options choisies
    #
    c << "Options d'envoi".in_div(class: 'titre')
    options_choisies = OPTIONS.reject{|k, e| e[:value] == false}.collect{|k, e| "#{e[:hname]}<br />"}.join('')
    if OFFLINE && !force_offline?
      options_choisies.prepend("Puisque vous êtes OFFLINE et que l'option “Forcer offline” n'est pas choisie, le message ne sera pas vraiment envoyé (sauf pour Phil), il sera juste placé dans le dossier temporaire des mails.<br />".in_span(class: 'warning'))
    end
    c << options_choisies.in_div(id: 'mailing_options', class: 'cadre')

    # Les options mémorisées
    # ----------------------
    # On met '1' pour celle qui sont vraies
    # et '0' pour celles qui sont fausses
    options_hidden =
      OPTIONS.collect do |koption, doption|
        "#{koption}:#{doption[:value] ? '1' : '0'}"
      end.join('::')

    # Formulaire d'envoi final du message
    #
    f = ""
    f << 'mailing_send'   .in_hidden(name: 'operation')
    f << subject.in_hidden(name: 'mail_subject')
    f << template_formated.in_textarea(name: 'template_formated', class: 'hidden')
    f << keys_destinataires.join(" ").in_hidden(name: 'keys_destinataires')
    f << options_hidden.in_hidden(name: 'options_hidden')
    f << "Envoyer".in_submit(class: 'btn main').in_div(class: 'buttons')
    c << f.in_form(id: 'form_send_message', action: 'admin/mailing', class: 'dim1090')

    self.content = c.in_div(id: "div_mailing_confirmation")

  rescue Exception => e
    debug e
    error e.message
  end

  #   / FIN DES OPÉRATIONS
  #
  # ---------------------------------------------------------------------


  #
  #
  # Définit les valeurs :value et :checked des options en
  # fonction des paramètres courant
  #
  def define_init_options
    KEYS_DESTINATAIRES.each do |key, dkey|
      KEYS_DESTINATAIRES[key][:checked] = param("cb_dest_#{key}".to_sym) == 'on'
    end
    options_hidden =
      if param(:options_hidden)
        h = Hash.new
        param(:options_hidden).split('::').each do |paire|
          paire = paire.split(':')
          h.merge!(paire.first.to_sym => paire.last == '1')
        end
        h
      else
        nil
      end
    OPTIONS.each do |key, dkey|
      OPTIONS[key][:value] =
        if options_hidden
          !!options_hidden[key]
        else
          param("cb_option_#{key}".to_sym) == 'on'
        end
    end
  end

  #
  #
  # Méthode appelée par `exec_prepare_mailing' pour checker
  # les valeurs transmises à la préparation du mailing
  #
  def define_params_and_check_values_or_raise
    @subject = param_mail[:subject].nil_if_empty
    @subject != nil || (raise 'Il faut définir le sujet du message.')
    @message = param_mail[:message].nil_if_empty
    @message != nil || (raise 'Il faut définir le corps du message.')
    @keys_destinataires = get_keys_destinataires
    !@keys_destinataires.empty? || (raise 'Il faut choisir les destinataires.')
    @options = get_options
  end

  def param_mail
    @param_mail ||= param(:mail) || Hash.new
  end

  # Retourne les options d'envoi et de traitement
  #
  def get_options
    [:code_brut].collect do |key|
      key if param("cb_option_#{key}".to_sym) == "on"
    end.reject { |e| e.nil? }
  end

  # Retourne les destinataires choisis
  def get_keys_destinataires
    KEYS_DESTINATAIRES.collect do |key, dkey|
      key if param("cb_dest_#{key}".to_sym) == "on"
    end.reject { |e| e.nil? }
  end

  # Pour l'exposer publiquement
  def bind; binding() end

  # Pour définir les variables d'instance (en mode test)
  def set hdata
    hdata.each { |k, v| self.instance_variable_set("@#{k}", v) }
  end

end #/<< self
end #/ Mailing
end #/ Admin
