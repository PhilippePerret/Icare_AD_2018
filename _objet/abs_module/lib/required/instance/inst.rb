# encoding: UTF-8
class AbsModule
  include MethodesMySQL

  def initialize id = nil # quand nouveau
    @id = id
  end

end #/AbsModule
