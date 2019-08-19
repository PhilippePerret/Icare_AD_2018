# encoding: UTF-8
class Icarien

  def initialize id
    @id = id
  end

  # ---------------------------------------------------------------------
  #   Propriétés de base (utiles à icarien)
  # ---------------------------------------------------------------------
  attr_reader :id

  def pseudo    ; @pseudo ||= owner.pseudo    end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles (hors listes)
  # ---------------------------------------------------------------------

  # En fait, l'user
  def owner ; @owner ||= User.new(id) end

end #/Icarien
