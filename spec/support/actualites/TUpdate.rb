# encoding: UTF-8

# site.require_objet 'actualite'

class TUpdate

  # ÇA PLANTE, POUR UNE RAISON INCONNUE………………
  # include ModuleTestTimeMethodes

  def initialize data
    @data = data
    dispatch(data)
  end

  def dispatch hdata
    hdata.each{|k,v|instance_variable_set("@#{k}",v)}
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe options = nil
    res = DB.getUpdate(@data)
    unless res.nil?
      @data = res
      dispatch(@data)
    end
    res != nil
  end

  def data
    @data
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def ref
    des = "l'actualité #{data.inspect}"
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
    @user_id ||= data[:user_id]
  end
end
