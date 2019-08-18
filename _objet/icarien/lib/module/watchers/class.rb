# encoding: UTF-8
=begin

=end
class Watchers
class << self

  # Table contenant tous les watchers
  def table
    @table ||= site.dbm_table(:hot, 'watchers')
  end
  
end #/<<self
end #/Watchers
