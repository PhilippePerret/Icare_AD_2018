# encoding: UTF-8
class User

  # Retourne l'instance de l'ic-module courant de l'user ou nil
  # si l'user n'a plus d'ic-module
  def icmodule
    @icmodule ||= begin
      if icmodule_id.nil?
        nil
      else
        site.require_objet 'ic_module'
        IcModule.new(icmodule_id)
      end
    end
  end
  # Returne une instance {Icmodules} gérant l'ensemble des
  # modules de l'icarien
  def icmodules
    @icmodules ||= begin
      User.require_module 'icmodules'
      Icmodules.new(self)
    end
  end

end #/User
