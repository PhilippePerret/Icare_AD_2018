# encoding: UTF-8
=begin

  Ce module ne doit être atteint que par ajax

=end
class User
  def can_vote_pour_pcomment? pcom_id
    liste_votes = get_var(:page_comments_ids, Array.new)
    # debug "liste_votes : #{liste_votes.inspect} (id fourni : #{pcom_id})"
    if liste_votes.include?(pcom_id)
      return false
    else
      liste_votes << pcom_id
      set_vars( page_comments_ids: liste_votes )
      return true
    end
  end
end
class Page
  class Comments
    def add_vote sens
      prop = (sens == 'up') ? :votes_up : :votes_down
      new_value = get(prop) + 1
      dtable = table.get(self.id)
      set(prop => new_value)
      dtable = table.get(self.id)
      return new_value
    end
  end #/Comments
end #/Page

if user.identified?
  pcom_id = site.current_route.objet_id
  if user.can_vote_pour_pcomment?(pcom_id)
    retour = Page::Comments.new(pcom_id).add_vote(param(:vote))
    Ajax << {vote_ok: true, votes_newvalue: retour}
    flash "Merci #{user.pseudo} pour votre vote."
  else
    error 'Vous ne pouvez voter qu’une seule fois pour un commentaire.'
  end
else
  Ajax << {vote_ok: false}
  error 'Désolé, seuls les visiteurs inscrits peuvent voter.'
end
