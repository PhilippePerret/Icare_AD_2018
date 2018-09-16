# encoding: UTF-8
class IcModule

  include MethodesMySQL
  include MethodesWatchers

  def initialize id
    @id = id
  end

  def table ; @table ||= self.class.table end

end #/IcModule
