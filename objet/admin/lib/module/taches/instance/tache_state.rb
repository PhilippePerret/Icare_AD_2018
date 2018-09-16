# encoding: UTF-8
class Admin
class Taches
class Tache

  def ended?
    state == 9
  end
  alias :complete? :ended?

  # Retourne true si la tache doit être faite
  # aujourd'hui
  def today?
    @is_today ||= echeance >= Today.start && echeance <= Today.end
  end

end #/Tache
end #/Taches
end #/Admin
