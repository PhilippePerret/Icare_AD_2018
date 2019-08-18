# encoding: UTF-8
=begin

=end
class User
class Icmodules
class Icetapes
class << self

  # Table contenant toutes les ic-etapes
  def table
    @table ||= site.dbm_table(:modules, 'icetapes')
  end

end #/<< self
end #/Icetapes
end #/Icmodules
end #/User
