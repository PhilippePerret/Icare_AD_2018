# encoding: UTF-8
class IcPaiement

  include MethodesMySQL

  def initialize id = nil
    @id = id
  end

  def table; @table ||= self.class.table end

end #/IcPaiement
