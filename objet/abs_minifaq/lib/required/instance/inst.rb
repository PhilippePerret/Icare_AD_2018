# encoding: UTF-8
class AbsModule
class AbsEtape
class AbsMinifaq

  include MethodesMySQL


  def table; @table ||= self.class.table end
  
end #/AbsMinifaq
end #/AbsEtape
end #/AbsModule
