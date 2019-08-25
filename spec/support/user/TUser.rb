# encoding: UTF-8
class TUser
class << self

  # Retourne le nombre actuel de user dans la base
  def count
    DB.count('icare_users.users')
  end

end #/<< self
end #/TUser
