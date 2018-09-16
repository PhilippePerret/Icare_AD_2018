# encoding: UTF-8
class SiteHtml
  def envoyer
    current_mail.send
  end

  def current_mail
    @current_mail ||= Contact.new
  end

  class Contact

    attr_reader :sent

    # Envoi du message
    def send
      valide? || return
      destinataire != nil || return
      if site.send_mail data_mail
        @sent = true
      end
    end

    def sent?
      @sent === true
    end
    def valide?
      subject != nil              || raise('Il faut indiquer le sujet de votre message.')
      subject.length >= 5         || raise('Votre sujet est trop court pour être vrai…')
      message != nil              || raise( "Il faut indiquer le contenu de votre message.")
      message.length > 5          || raise( "Votre message est trop court pour être vrai…")
      sender != nil               || raise( "Il faut indiquer votre adresse mail, pour pouvoir recevoir une réponse.")
      sender == confirmation_mail || raise( "La confirmation de votre mail ne correspond pas…")
      captcha != nil              || raise('Il faut fournir le captcha pour nous assurer que vous n’êtes pas un robot.')
      app.captcha_valid?(captcha) || raise('Le captcha est mauvais, seriez-vous un robot ?')
    rescue Exception => e
      error e.message
    else
      true
    end

    def data_mail
      @data_mail ||= {
        to:       destinataire.mail,
        from:     sender,
        subject:  subject,
        message:  message_final,
        formated: false
      }
    end

    # Destinataire. Si param(:to), c'est un icarien, sinon c'est
    # l'administration du site
    def destinataire
      @destinataire ||= begin
        if param(:to)
          dest_id = param(:to).to_i
          dest_id > 0 || raise('Opération impossible…')
          dest = User.new(dest_id)
          (user.identified? && dest.pref_type_contact < 2) || (dest.pref_type_contact_world < 2) || begin
            if user.identified?
              raise "#{user.pseuco}, vous n’êtes pas autorisé#{user.f_e} à écrire à cet icarien."
            else
              raise "Non, vous n'êtes pas autorisé à écrire à cet icarien."
            end
          end
          dest
        else
          User.new(1)
        end
      rescue Exception => e
        error e
        nil
      end
    end
    def subject
      @subject ||= data[:sujet].nil_if_empty
    end

    # Le message final
    # ----------------
    # Il sera encadré si c'est un message qui s'adresse à un
    # icarien plutôt qu'à l'administration
    def message_final
      <<-HTML
<p>Bonjour #{destinataire.pseudo},</p>
<p>Un message vient de vous être envoyé depuis le site de l'atelier Icare par : #{sender_designation} :</p>
<fieldset>
<legend>Le message transmis</legend>
#{message}
</fieldset>
      HTML
    end

    # Pour la désignation de l'expéditeur dans le mail
    def sender_designation
      if user.identified?
        "#{user.pseudo} (#{user.mail})"
      else
        "un visiteur ayant pour adresse #{sender}"
      end
    end

    # Message protégé contre les injections quelconque
    def message
      @message ||= begin
        m = data[:message].nil_if_empty
        m.nil? || begin
          m = m.strip_tags
        end
        m
      end
    end

    def sender
      @sender ||= data[:mail] || (user.identified? ? user.mail : nil)
    end

    def mail_confirmation
      @mail_confirmation ||= data[:mail_confirmation]
    end
    alias :confirmation_mail :mail_confirmation

    def data
      @data ||= param(:contact) || Hash.new
    end

    def captcha
      @captcha ||= data[:captcha].nil_if_empty.to_i_inn
    end

  end
end
