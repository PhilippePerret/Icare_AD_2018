# encoding: UTF-8

site.require_module('Ticket')

class TTicket

  attr_reader :id, :user_id, :code, :created_at, :updated_at
  attr_reader :wdata

  def initialize wdata
    @wdata = wdata
    wdata.each{|k,v|instance_variable_set("@#{k}",v)}
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe options = nil
    res = DB.getTicket(@wdata)
    @wdata = res unless res.nil?
    res != nil
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def ref
    ref = "le ticket #{wdata.inspect}"
    user.nil? || ref << " concernant #{user.pseudo} (##{user.id})"
    data.nil? || ref << " avec les données #{wdata}"
    ref << "."
  end
  alias :designation :ref

  def user
    @user ||= begin
      if wdata && wdata[:user_id]
        User.get(wdata[:user_id])
      end
    end
  end
end
