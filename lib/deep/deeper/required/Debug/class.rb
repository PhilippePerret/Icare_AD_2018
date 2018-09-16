# encoding: UTF-8
=begin

  Class Debug
  -----------
  Gestion du débuggage

  Cette classe a été créée au départ pour créer une méthode
  `Debug::escape` qui permette d'escaper les messages pour le
  debug de bas de page.

=end
class Debug
class << self

  def escape str
    str =
      case str
      when Symbol       then str.inspect
      when Hash, Array  then str.inspect
      else str
      end
    str.to_s.gsub(/</,'&lt;')
  end

end #/<< self
end #/Debug
