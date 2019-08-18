# encoding: UTF-8
class AbsModule
class AbsEtape
class AbsTravailType

  extend MethodesMainObjet

  class << self

    def table
      @table ||= dbtable_travaux_types
    end

    def titre
      @titre ||= "Travail type"
    end

    def data_onglets
      {
        'Liste' => 'abs_travail_type/list'
      }
    end

  end #/<<self
end #/AbsTravailType
end #/AbsEtape
end #/AbsModule
