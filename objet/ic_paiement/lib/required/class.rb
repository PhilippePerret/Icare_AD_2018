# encoding: UTF-8
class IcPaiement

  extend MethodesMainObjet

  class << self

    def table ; @table ||= User.table_paiements end

  end #/<< self
end #/IcPaiement
