# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  include MethodesMySQL
  include MethodesWatchers

  def initialize id
    @id = id
  end

  def table ; @table ||= self.class.table end

end #/IcDocument
end #/IcEtape
end #/IcModule
