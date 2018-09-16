# encoding: UTF-8

class User
  def owner?
    site.current_route.objet_id.nil? || user.id == site.current_route.objet_id
  end
end
