# encoding: UTF-8
=begin

=end
class User
class Icmodules
class << self

  # Table des ic-modules
  def table
    @table ||= site.dbm_table(:modules, 'icmodules')
  end

end #/<< self
end #/Icmodules
end #/User
