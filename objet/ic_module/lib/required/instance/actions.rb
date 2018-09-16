# encoding: UTF-8
class IcModule

  # Ajoute un paiement au module
  # +paiement_id+ {Fixnum} IDentifiant du paiement dans la table
  # des paiements (users.paiements)
  def add_paiement paiement_id
    arr = paiements_ids.dup
    arr << paiement_id
    set(paiements: arr.join(' '))
    @paiements_ids = nil
  end

end #/IcModule
