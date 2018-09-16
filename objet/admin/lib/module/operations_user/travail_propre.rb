# encoding: UTF-8
class Admin
class Users
class << self

  def exec_travail_propre
    icarien.actif? || raise('On ne peut définir le travail propre que d’un icarien actif, voyons !')
    if long_value.nil?
      # Si le travail propre est nil, c'est qu'il faut le charger
      @long_value = icarien.icetape.travail_propre || ''
      param(long_value: @long_value)
    else
      icarien.icetape.set(travail_propre: long_value)
      flash "Le travail propre a été défini pour #{icarien.pseudo}. Pour le voir, il suffit de visiter comme… #{icarien.pseudo} depuis le bureau."
    end
  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
