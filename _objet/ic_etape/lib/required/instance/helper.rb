# encoding: UTF-8
class IcModule
class IcEtape
  # Raccourcis
  def numero
    @numero ||= abs_etape.numero
  end
  # Pour l'annonce d'actualité, pour le moment
  def designation
    @designation ||= "étape #{numero} du module “#{self.icmodule.abs_module.name}”"
  end
  
end#/IcEtape
end #/IcModule
