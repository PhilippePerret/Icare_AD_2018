# encoding: UTF-8
class User

  # Les trois états dans lequel peut être l'icarien :
  #               bit_state (bit 16)
  #   actif?        2
  #   inactif?      4
  #   pause?        8
  #

  # True si c'est un vrai icarien, c'est-à-dire s'il
  # a déjà procédé à un paiement. C'est le bit 'reality' qui
  # consigne cette valeur
  def real_icarien? ; bit_reality == 1 || admin? end
  # True si l'icarien est à l'essai, c'est-à-dire qu'il
  # n'a jamais procédé au moindre paiement.
  def alessai? ; bit_reality == 0 && !admin? end
  alias :essai? :alessai?

  # Retourne true si l'user est inscrit, reçu ou non
  # Noter que c'est nécessaire car une instance User existe même pour
  # un simple visiteur non inscrit.
  def icarien?
    bit_state > 0
  end
  def en_attente?
    bit_state == 1
  end
  # Retourne True si ce n'est pas un icarien qui vient de
  # s'inscrire
  def recu?
    bit_state > 1
  end
  def actif?
    bit_state == 2 && !en_pause?
  end
  
  # Gestion de la pause
  def en_pause?
    bit_state == 8 || (icmodule != nil && icmodule.en_pause?)
  end
  def set_en_pause    ; set_option(16,3) end
  def unset_en_pause  ; set_option(16,2) end

  def inactif?
    bit_state == 4
  end

end #/User
