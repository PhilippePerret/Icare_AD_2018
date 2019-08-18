# encoding: UTF-8
class Frigo
class Discussion

  # Destruction d'un discussion
  #
  # Une confirmation est demandée avant de procéder à l'opération.
  #
  def remove
    # Impossible de détruire une discussion si on n'est pas le propriétaire
    # du frigo
    frigo.owner? || begin
      raise 'Seriez-vous en train de vouloir détruire une discussion qui ne vous appartient pas ?…'
    end

    if confirmation_removing?
      interloc  = interlocuteur_designation.freeze
      upseudo   = user_pseudo.freeze
      dis_id = self.id.freeze
      dbtable_frigo_discussions.delete(dis_id)
      dbtable_frigo_messages.delete(where:{discussion_id: dis_id})
      site.send_mail(
        to: user_mail, from: site.mail,
        subject:    'Destruction de discussion sur un frigo',
        formated:   true,
        message:    <<-HTML
<p>Bonjour #{upseudo},</p>
<p>Je vous informe que #{frigo.owner.pseudo} vient de détruire la conversation qu'#{frigo.owner.f_elle} avait avec vous sur son bureau de l'atelier Icare.</p>
<p>Cordialement,</p>
        HTML
      )
      flash "Discussion avec #{interloc} détruite."
    else
      # Il faut demander confirmation
      form = (
        self.id.in_hidden(name:'discussion_id') +
        'remove_discussion'.in_hidden(name:'operation') +
        'confirmed'.in_hidden(name:'confirmation_removing') +
        "Confirmer la destruction de la discussion avec #{interlocuteur_designation}".in_submit(class: 'btn medium warning').in_div(class: 'right')
      ).in_form(action: "bureau/#{frigo.owner_id}/frigo", class: 'air')
      flash <<-HTML
<p>Voulez-vous vraiment détruire cette discussion avec #{interlocuteur_designation} ?</p>
<p>Si vous confirmez, tous ses messages seront définitivement détruits, sans possibilité de retour en arrière.</p>
#{form}
      HTML
    end
  end
  def confirmation_removing?
    param(:confirmation_removing) == 'confirmed'
  end
end #/Discussion
end #/Frigo
