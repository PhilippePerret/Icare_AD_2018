# encoding: UTF-8
=begin

=end
class User
class Icmodules

  # {User} Propriétaire des icmodules de cette ensemble
  attr_reader :owner

  def initialize owner
    @owner = owner
  end

  # Retourne la liste de tous les icmodules de l'icarien
  def list
    self.class.table.select(where: {user_id: owner.id})
  end

  # Méthode administration permettant de détruire
  # tous les ic-modules de l'user
  def remove
    self.class.table.delete(where: { user_id: owner.id })
    @list = nil
  end

end #/Icmodules
end #/User
