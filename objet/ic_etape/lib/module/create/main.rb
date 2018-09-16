# encoding: UTF-8
class IcModule::IcEtape
class << self

  # = main =
  #
  # Méthode principale qui créer l'étape de numéro +numero+ pour
  # l'icmodule +icmodule+ (instance IcModule)
  #
  # Ne pas appeler cette méthode directement, mais passer par :
  #   IcModule::IcEtape.create_for icmodule, numero
  #
  # RETURN l'icetape créée (instance IcModule::IcEtape)
  #
  # Noter que l'icetape_id n'est pas modifié dans l'ic-module, il faut
  # le faire dans la méthode appelante, grâce à l'instance retournée.
  #
  def _create_for icmodule, numero
    icetape_id = dbtable_icetapes.insert(data_icetape_for icmodule, numero)
    return new(icetape_id)
  end

  # Data de l'ic-étape
  # ------------------
  # Note : la méthode est "isolée" pour pouvoir être utilisée par les tests pour
  # les simulations.
  def data_icetape_for icmodule, numero
    habs_etape = dbtable_absetapes.get(where: {module_id: icmodule.abs_module.id, numero: numero})
    habs_etape != nil || raise("Impossible d'obtenir les données de l'étape absolue de numero #{numero.inspect} pour l'abs_module ##{icmodule.abs_module.id.inspect} (icmodule.abs_module.name)")

    expected_end = Time.now.to_i + (habs_etape[:duree]||7).days

    data_icetape = {
      user_id:        icmodule.user_id,
      abs_etape_id:   habs_etape[:id], # ça c'est nouveau
      icmodule_id:    icmodule.id,
      numero:         numero,
      started_at:     Time.now.to_i, # Correspond à la date de création de la donnée
      expected_end:   expected_end,
      status:         1,
      updated_at:     Time.now.to_i
    }
  end

end #/self
end #/IcModule::IcEtape
