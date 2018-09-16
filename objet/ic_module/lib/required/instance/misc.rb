# encoding: UTF-8
class IcModule

  def stop
    # Si le module était en pause, il faut le sortir de
    # sa pause
    en_pause? && stop_pause
    # On marque sa fin
    set(ended_at: Time.now.to_i)
    # On indique qu'il n'est plus le module courant de
    # l'icarien
    icarien.set(icmodule_id: nil)
  end
  
end #/IcModule
