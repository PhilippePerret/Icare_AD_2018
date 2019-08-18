# encoding: UTF-8
class Frigo

  attr_reader :owner_id

  def initialize uid ; @owner_id = uid end
  # Le propriétaire du frigo
  def owner ; @owner ||= User.new(owner_id) end

end #/Frigo
