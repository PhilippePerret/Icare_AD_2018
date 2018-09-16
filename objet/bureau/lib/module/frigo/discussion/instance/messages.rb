# encoding: UTF-8
class Frigo
class Discussion

  # Tous les messages de cette discussion. C'est une liste
  # d'instance Frigo::Discussion::Message
  def messages
    drequest = {
      where:    {discussion_id: self.id},
      order:    'created_at ASC',
      colonnes: []
    }
    dbtable_frigo_messages.select(drequest).collect do |hmess|
      Frigo::Discussion::Message.new( hmess[:id] )
    end
  end


  # Création d'un message pour la discussion courante
  #
  # La méthode est appelée quand on soumet le formulaire pour
  # un nouveau message.
  def create_message
    app.checkform_on_submit # pour empêcher les rechargements
    data_new_message_ok? || return
    message_id = dbtable_frigo_messages.insert(data_new_message)
    avertir_owner_or_interlocuteur(message_id)
  rescue AlreadySubmitForm => e
    error e.message
  end

  def data_new_message
    @data_new_message ||= begin
      now = Time.now.to_i
      contenu = param(:frigo_message).strip_tags
      contenu = contenu.
                  gsub(/\*\*(.*?)\*\*/, '<strong>\1</strong>').
                  gsub(/\*(.*?)\*/, '<em>\1</em>').
                  gsub(/_(.*?)_/, '<u>\1</u>')
      contenu = contenu.nil_if_empty
      {
        content:        contenu,
        discussion_id:  self.id,
        auteur_ref:     (frigo.owner? ? 'o' : 'i'),
        created_at:     now,
        updated_at:     now
      }
    end
  end
  def data_new_message_ok?
    data_new_message[:content] != nil || raise('Il faut écrire le message, voyons…')
    # Il faut vérifier que la discussion appartienne bien à l'interlocuteur
    # ou le propriétaire
    frigo.owner? || self.user_id == user.id || raise('Vous ne faites pas partie de cette discussion…')
  rescue Exception => e
    debug e
    error e
  else
    true
  end


  # Méthode pour avertir par mail le propriétaire ou l'interlocuteur
  #
  # +message+ Instance Frigo::Discussion::Message du message qui
  # va générer le mail.
  #
  def avertir_owner_or_interlocuteur(message)
    message.instance_of?(Fixnum) && message = Frigo::Discussion::Message.new(message)
    tomail, pseudo, autre, sujet_mail, votre =
      if frigo.owner?

        [
          user_mail, user_pseudo, frigo.owner.pseudo,
          "Nouveau message de la part de #{frigo.owner.pseudo}",
          'son'
        ]
      else
        [
          frigo.owner.mail, frigo.owner.pseudo, user_pseudo,
          'Un nouveau message sur votre frigo !',
          'votre'
        ]
      end
    lien_mot = 'un petit mot pour vous'.in_a(href: message.url)
    site.send_mail(
      to:       tomail,
      from:     site.mail,
      subject:  sujet_mail,
      formated: true,
      message:  <<-HTML
<p>Bonjour #{pseudo},</p>
<p>Un message pour vous informer que <strong>#{autre}</strong> vient de laisser #{lien_mot} sur #{votre} bureau de l'atelier Icare.</p>
<p>Bien à vous,</p>
      HTML
    )
  end

end #/Discussion
end #/Frigo
