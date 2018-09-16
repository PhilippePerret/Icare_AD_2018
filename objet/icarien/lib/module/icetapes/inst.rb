# encoding: UTF-8
=begin

=end
class User
class Icmodules
class Icetapes

  # {User} Propriétaire de l'ensemble d'icetapes
  attr_reader :owner

  def initialize owner
    @owner = owner
  end

  # Destruction de toutes les ic-étapes du propriétaire
  # Note : usage réservé aux tests et ne peux pas être
  # déclenché autrement que par les tests
  def remove
    self.class.table.delete(where: {user_id: owner.id})
  end

end #/Icetapes
end #/Icmodules
end #/User
