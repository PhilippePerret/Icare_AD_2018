# encoding: UTF-8
class Admin
class Mailing
class << self
  # Opération d'envoi véritable du message
  #
  def exec_mailing_send
    @template_formated = param(:template_formated).nil_if_empty
    @template_formated != nil || (raise "Le message template n'est pas défini.")
    @subject = param(:mail_subject).nil_if_empty
    subject != nil || (raise "Le sujet du mail n'est pas défini.")
    param(:keys_destinataires) != nil || (raise "Les clés des destinataires ne sont pas fournis…")
    param(:keys_destinataires).split(' ').each do |kdestinataire|
      KEYS_DESTINATAIRES[kdestinataire.to_sym][:checked] = true
    end

    rapport = Array.new
    destinataires.each do |u|
      begin
        # ==============================
        # ===== ENVOI DU MESSAGE =======
        # ==============================
        send_message_to u
        rapport << "Message envoyé à #{u.pseudo} (#{u.mail})".in_div
      rescue Exception => e
        rapport << "# ERREUR : Impossible d'envoyer le message à #{u.mail} : #{e.message}".in_span(class: 'warning')
      end
    end

    begin
      send_message_to admin, (forcer = true)
      rapport << "Message envoyé en réel à Phil".in_div
      ONLINE || begin
        send_message_to( User.new(2) )
        rapport << "Message envoyé à Marion".in_div
      end
    rescue Exception => e
      error "Impossible d'envoyer le message à l'administrateur."
      rapport << "# IMPOSSIBLE d'envoyer le message à l'administrateur."
    end

    self.content = ("Rapport de mailing".in_div(class: 'bold big air') + rapport.join('')).in_div(id: "rapport_mailing", class: 'cadre small')
  end
  # /opération exec_mailing_send

  # Procède à l'envoi du message
  #
  # +u+ L'user
  def send_message_to u, forcer_offline = false
    u.instance_of?(User) || (raise ArgumentError, "Il faut fournir un User en premier argument.")
    data_mail = {
      subject:  subject,
      message:  real_message_for(u)
    }
    OFFLINE && (forcer_offline || force_offline?) && data_mail.merge!(force_offline: true)

    (code_html? || code_erb?) && data_mail.merge!(formated: true)

    u.send_mail data_mail
  end

end #/<< self
end #/Mailing
end #/Admin
