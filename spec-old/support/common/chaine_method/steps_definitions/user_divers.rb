# encoding: UTF-8
class User

  # Pour simuler le rechargement de la page
  #
  # @usage :      <Someone> recharge
  # @exemples :   Phil recharge
  #               sim.user recharge
  def recharge
    cpage.evaluate_script("window.location.reload()")
  end

end #User
