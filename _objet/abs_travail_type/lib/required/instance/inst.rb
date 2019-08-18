# encoding: UTF-8
class AbsModule
class AbsEtape
class AbsTravailType

  include MethodesMySQL

  def initialize id
    @id = id
  end

  def table ; @table ||= self.class.table end

  def bind ; binding() end

end #/AbsTravailType
end #/AbsEtape
end #/AbsModule
