# encoding: UTF-8
class AbsModule
class AbsEtape
  extend MethodesMainObjet

class << self

  def table ; @table ||= site.dbm_table(:modules, 'absetapes') end

  def titre ; @titre ||= "Étape d'apprentissage" end

  def data_onglets
    {}
  end

end #/<< self
end #/AbsEtape
end #/#AbsModule
