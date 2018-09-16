# encoding: UTF-8
class Icarien
  extend MethodesMainObjet
  class << self

    def table ; @table ||= dbtable_users end

    def titre ; @titre ||= 'Les Icariens' end

    def data_onglets
      {
        "Liste" => 'icarien/list'
      }
    end

  end #/<< self
end #/Icarien
