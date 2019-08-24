# encoding: UTF-8

site.require_objet 'watcher'

class TWatcher

  include ModuleTestTimeMethodes

  attr_reader :user_id, :objet, :objet_id, :processus, :data

  def initialize wdata
    @wdata = wdata
    wdata.each{|k,v|instance_variable_set("@#{k}",v)}
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe options = nil
    res = DB.getWatcher(@wdata)
    @wdata = res unless res.nil?
    res != nil
  end

  def wdata
    @wdata
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def ref
    des = "le watcher #{wdata.inspect}"
    des << times_for_designation
    user.nil? || des << " concernant #{user.pseudo} (##{user.id})"
    data.nil? || des << " avec les données #{wdata}"
    "#{des}."
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
