# encoding: UTF-8
class Frigo

  # Retourne TRUE si le visiteur courant est le propriétaire du
  # frigo
  def owner?
    @is_owner === nil && @is_owner = (user.id == owner_id)
    @is_owner
  end

  # Retourne true si le frigo peut être utilisé par un
  # icarien
  def available_for_icarien?
    [0,2].include?(owner.pref_type_contact)
  end

  # Retourne true si le frigo peut être utilisé par le quidam
  # Noter que c'est une propriété de l'user, pas du frigo
  def available_for_world?
    [0,2].include?(owner.pref_type_contact_world)
  end

  # Retourne true si le frigo existe (dans la table), false dans
  # le cas contraire
  def exist?
    dbtable_frigos.count(where: {id: owner_id}) > 0
  end

  # Retourne l'instance de la discussion si le propriétaire du frigo
  # courant a une discussion avec le visiteur courant, qui peut être
  # reconnu par son ID si c'est un icarien ou par son mail s'il l'a
  # fourni.
  def has_discussion_with_current?
    discussion_with_current != nil
  end

  def discussion_with_current
    if user.identified?
      dbtable_frigo_discussions.get(where:{user_id: user.id, owner_id: frigo.owner_id})
    elsif param(:qmail) # note : "q" pour "quidam"
      # C'est un visiteur qui vient d'entrer son adresse mail
      dbtable_frigo_discussions.get(where:{user_mail: param(:qmail), owner_id: frigo.owner_id})
    else
      nil
    end
  end

end #/Frigo
