# encoding: UTF-8
class IcModule
class IcEtape

  include MethodesMySQL
  include MethodesWatchers

  def initialize eid, inst_data = nil
    @id = eid
    inst_data.nil? || inst_data.each{|k,v|instance_variable_set("@#{k}",v)}
  end

  def table ; @table ||= self.class.table end

  def bind ; binding() end

end #/IcEtape
end #/IcModule
