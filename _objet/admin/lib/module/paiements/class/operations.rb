# encoding: UTF-8
class Admin
class Paiements
class << self

  # = main =
  #
  # Pour afficher les paiements demandés
  def afficher
    new(param(:fromto)).output
  end

end #/Self
end #/Paiements
end #/Admin
