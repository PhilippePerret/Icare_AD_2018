# encoding: UTF-8
=begin
Les méthode "if not nil" (INN/inn) permettent de simplifier les codes en ne
transtypant une valeur que si elle n'est pas nil.
Par exemple, si on peut avoir en paramètre :num_etape, mais qu'elle peut
être nil aussi, on utilise `num_etape = param(:num_etape).to_i_inn` qui
signifie ("to integer if not nil") et qui laissera num_etape à NIL si le
paramètre n'est pas défini ou au contraire qui transformera la valeur
string en integer si elle est définie.
Noter également que pour les strings, ils ne sont transformés en valeurs
que s'ils ne sont pas vides. Une chaine vide renverra toujours NIL avec
ces méthodes.
=end
class ::NilClass
  def to_i_inn;     nil end
  def to_sym_inn;   nil end
  def to_s_inn;     nil end
end
class ::String
  # transforme le string en entier si c'est bien
  # un string.
  def to_i_inn
    self == "" ? nil : self.to_i
  end
  # Transforme en Symbol si c'est bien un string
  def to_sym_inn
    self == "" ? nil : self.to_sym
  end
end
class ::Symbol
  # Transforme en String si c'est bien un symbol.
  def to_s_inn
    self.to_s
  end
end
