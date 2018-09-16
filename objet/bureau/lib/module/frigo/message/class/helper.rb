# encoding: UTF-8
class Frigo
class Discussion
class Message
class << self

  # Retourne le formulaire pour laisser un message sur le frigo
  # de l'icarien
  def form_message premier = true
    # Si c'est une discussion publique, et qu'aucun interlocuteur ou
    # propriétaire n'est défini, on ne met pas de formulaire
    frigo.owner? || param(:qmail) || user.identified? || (return '')
    init_discussion_if_needed
    (
      inner_form(premier)
    ).in_div(class: 'boite_new_message')
  end

  # Avant de construire le formulaire pour un nouveau message, on doit
  # instancier la discussion si elle n'existe pas vraiment. Noter qu'elle
  # restera vide si aucun message n'est enregistré, mais c'est préférable
  # et plus facile de fonctionner comme ça.
  def init_discussion_if_needed
    frigo.has_discussion_with_current? || begin
      dis = Frigo::Discussion.new
      dis.create
      frigo.current_discussion= dis
    end
  end

  def inner_form premier
    mess_destinataire =
      if frigo.owner?
        frigo.current_discussion.user_pseudo
      else
        frigo.owner.pseudo
      end
    mess_destinataire = "#{premier ? 'Premier message' : 'Réponse ou nouveau message'} pour #{mess_destinataire}"
    (
      'save_message_frigo'.in_hidden(name:'operation') +
      # Pour savoir si les discussions sont affichées ou masquées
      (param(:masked_discussions)||'').in_hidden(name: 'masked_discussions') +
      app.checkform_hidden_field('form_new_message') +
      frigo.current_discussion.id.in_hidden(name: 'frigo_discussion_id', id: 'frigo_discussion_id') +
      param(:qmail).in_hidden(name:'qmail', id: 'frigo_mail') +
          # Noter que param(:qmail) peut ne pas être défini, lorsque par exemple
          # c'est le propriétaire qui visite son frigo.
      ''.in_textarea(name:'frigo_message', id: 'frigo_message', placeholder: mess_destinataire, style: 'height:100px!important;width:94%;padding:1em') +
      'Déposer sur le frigo'.in_submit(class: 'btn small').in_div(class: 'buttons') +
      'Styles utilisables : **texte en gras** (<strong>texte en gras</strong>), *texte en italique* (<em>texte en italique</em>), _texte souligné_ (<u>texte souligné</u>)'.in_p(class: 'tiny')
    ).in_form(id: "form_new_message", action: "bureau/#{frigo.owner_id}/frigo")
  end

end #<< self
end #/Message
end #/Discussion
end #/Frigo
