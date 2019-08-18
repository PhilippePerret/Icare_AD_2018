# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  extend MethodesMainObjet

  class << self

    def table
      @table ||= site.dbm_table(:modules, 'icdocuments')
    end
    def table_lectures
      @table_lectures ||= site.dbm_table(:modules, 'lectures_qdd')
    end

    def titre
      'Document d’icarien'
    end

    def data_onglets
      {}
    end

    # Les options par défaut pour un document.
    # Noter que le '1' au début signifie que le document original
    # existe toujours.
    def default_options
      '1'+'0'*15
    end

  end #/<< self

end #/IcDocument
end #/IcEtape
end #/IcModule
