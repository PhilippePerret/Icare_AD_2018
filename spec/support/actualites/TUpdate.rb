# encoding: UTF-8

# site.require_objet 'actualite'

class TUpdate

  # ÇA PLANTE, POUR UNE RAISON INCONNUE………………
  # include ModuleTestTimeMethodes

  def initialize instdata
    @instdata = instdata
    dispatch(instdata)
  end

  def dispatch hdata
    hdata.each{|k,v|instance_variable_set("@#{k}",v)}
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe options = nil
    res = DB.getUpdate(@instdata)
    unless res.nil?
      @instdata = res
      dispatch(@instdata)
    end
    res != nil
  end

  def all_data
    @instdata
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def ref
    des = "l'actualité #{instdata.inspect}"
    user.nil? || des << "concernant #{user.pseudo} (##{user.id})"
    "#{des}."
  end
  alias :designation :ref

  def user
    @user ||= begin
      User.get(user_id) if user_id
    end
  end

  def user_id
    @user_id ||= instdata[:user_id]
  end
end
