# encoding: UTF-8
class AbsModule
class AbsEtape
  include MethodesMySQL

  def initialize id; @id = id end

  def table; @table ||= dbtable_absetapes end

  def bind; binding() end


end #/AbsEtape
end #/AbsModule
