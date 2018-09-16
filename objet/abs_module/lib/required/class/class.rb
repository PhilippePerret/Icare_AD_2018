# encoding: UTF-8
class AbsModule

  extend MethodesMainObjet

  class << self

    def table         ; @table ||= site.dbm_table(:modules, 'absmodules') end
    def table_online  ; @table_online ||= site.dbm_table(:modules, 'absmodules', true) end

    def titre
      @titre ||= "Modules d’apprentissage"
    end

    def data_onglets
      {}
    end

  end #/<< self
end #Absmodules
