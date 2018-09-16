# encoding: UTF-8
class AbsModule
class AbsEtape
class AbsMinifaq

  extend MethodesMainObjet

  class << self
    def titre
      "MiniFaq des étapes"
    end

    def data_onglets
      {}
    end

    def table ; @table ||= site.dbm_table(:modules, 'mini_faq') end
    
  end #/<< self
end #/AbsMinifaq
end #/AbsEtape
end #/AbsModule
