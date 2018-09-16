# encoding: UTF-8
class ::Range

  # Usage : (0..25).in_select
  # => produit un menu pour choisir une valeur de 0 à 25
  def in_select options = nil
    arr = self.collect { |el| [el, el ] }
    ( arr.in_select options )
  end
end
