# encoding: UTF-8
class Frigo
class Discussion

  def display
    is_displayed = param("discussion_masked_#{id}".to_sym) != '1'
    (
      self.titre +
      boutons_owner_or_message_interloc +
      messages.collect do |imess|
        imess.as_li
      end.join.in_ul(class: 'discussion') +
      Frigo::Discussion::Message.form_message(premier = false)
    ).in_div(id: "discussion-#{id}", class: 'discussion', display: is_displayed)
  end

  def boutons_owner_or_message_interloc
    if frigo.owner?
      boutons_owner
    else
      message_partage_interlocuteur
    end.in_div(class: 'btns_discussion')
  end

  # Lorsque c'est l'interlocuteur qui visite le fil, on lui
  # indique l'état de partage de la discussion
  def message_partage_interlocuteur
    "Cette discussion est #{shared_hvalue}".in_span(class: 'italic')
  end

  # Les boutons du propriétaire du frigo, pour détruire les
  # conversations, les rendre publiques, etc.
  def boutons_owner
    frigo.owner? || (return '')
    (
      menu_partage  +
      bouton_remove
    )
  end
  def bouton_remove
    (
      'remove_discussion'.in_hidden(name:'operation') +
      self.id.in_hidden(name: 'discussion_id')  +
      'Détruire'.in_submit(class: 'btn tiny warning')
    ).in_form(action: "bureau/#{frigo.owner_id}/frigo")
  end
  def menu_partage
    (
      'set_partage_discussion'.in_hidden(name:'operation') +
      self.id.in_hidden(name: 'discussion_id') +
      'Cette discussion est&nbsp;'.in_span +
      [
        ['0', 'confidentielle'],
        ['1', 'lisible par les icariens'],
        ['2', 'lisible par n’importe qui']
      ].in_select(
        name:       'discussion_partage',
        onchange:   'this.form.submit()',
        class:      'inline',
        selected:   self.options[0]
        )
    ).in_form(action:"bureau/#{frigo.owner_id}/frigo")
  end

end #/Discussion
end #/Frigo
