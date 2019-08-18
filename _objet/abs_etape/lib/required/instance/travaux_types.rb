# encoding: UTF-8
class AbsModule
class AbsEtape

  # Méthode appelée à l'évaluation du travail de la méthode lorsqu'elle
  # fait appel à des travaux-type
  def travail_type rubrique, short_name
    site.require_objet 'abs_travail_type'
    dreq = {
      where: {rubrique: rubrique, short_name: short_name},
      colonnes: []
    }
    hwt = dbtable_travaux_types.get(dreq)
    if hwt.nil?
      "[Impossible d'obtenir le travail-type #{rubrique}.#{short_name}]"
    else
      wt = AbsModule::AbsEtape::AbsTravailType.new(hwt[:id])
      wt.travail_formated
    end
  end

  # Retourne la liste des travaux types de l'étape sous
  # forme d'une instance d'ensemble {AbsModules::AbsEtapes::AbsTravauxTypes}
  def travaux_types
    @travaux_types ||= begin
      AbsModule::AbsEtape.require_module 'travaux_types'
      AbsModules::AbsEtapes::AbsTravauxTypes.new(self)
    end
  end

end #/AbsEtape
end #/AbsModule
