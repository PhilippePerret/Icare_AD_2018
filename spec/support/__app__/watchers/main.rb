# encoding: UTF-8


def le_watcher wdata
  require_objet_watcher_if_needed
  TWatcher.new(wdata)
end

def require_objet_watcher_if_needed
  @objet_watcher_required || begin
    site.require_objet 'watcher'
    @objet_watcher_required = true
  end
end


class TWatcher

  include ModuleTestTimeMethodes

  attr_reader :user_id, :objet, :objet_id, :processus, :data
  attr_reader :inst_data

  def initialize wdata
    @inst_data = wdata
    wdata.each{|k,v|instance_variable_set("@#{k}",v)}
    if @user != nil
      @user_id = user.id
    elsif @user_id != nil
      @user = User.new(@user_id)
    end
  end
  # ---------------------------------------------------------------------
  #   Méthodes de test
  # ---------------------------------------------------------------------
  def existe options = nil
    options ||= Hash.new
    message_success = options[:success] || "#{designation.capitalize} existe."
    message_failure = options[:failure] || "Impossible de trouver #{designation}"
    where = Array.new
    user_id.nil?    || where << "user_id    = #{user_id}"
    objet.nil?      || where << "objet      = '#{objet}'"
    objet_id.nil?   || where << "objet_id   = #{objet_id}"
    processus.nil?  || where << "processus  = '#{processus}'"
    data.nil?       || where << "data = \"#{data}\""
    where += where_time_tests
    drequest = {where: where.join(' AND ')}
    nombre = SiteHtml::Watcher.table.count(drequest)
    if nombre == 1
      success message_success
    else
      raise message_failure
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def designation
    des = "le watcher #{inst_data.inspect}"
    des << times_for_designation
    user.nil? || des << " concernant #{user.pseudo} (##{user.id})"
    data.nil? || des << " avec les données #{data}"
    "#{des}."
  end
end
