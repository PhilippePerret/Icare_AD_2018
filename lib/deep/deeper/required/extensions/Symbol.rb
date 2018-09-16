# encoding: UTF-8
class ::Symbol

  # Par exemple, lorsqu'un argument de fonction peut être
  # un array ou un string, cette méthode permet de ne pas
  # avoir à tester si l'élément est un array ou non.
  def in_array
    [self]
  end

  def in_hidden attrs = nil
    self.to_s.in_hidden attrs
  end

end
