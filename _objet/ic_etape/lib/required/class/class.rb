# encoding: UTF-8
class IcModule
class IcEtape

  extend MethodesMainObjet

class << self


  def table
    @table ||= site.dbm_table(:modules, 'icetapes')
  end

end #/<< self
end #/IcEtape
end #/IcModule
