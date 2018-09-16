# encoding: UTF-8
=begin
  Méthodes à inclure dans les classes de test qui doivent tester avec
  created_after, etc.

=end
module ModuleTestTimeMethodes

  attr_reader :created_after, :created_before
  attr_reader :updated_after, :updated_before

  # Retourne les éléments de la clause WHERE concernant les temps
  # en fonction des définitions. La donnée retournée doit être un
  # Array, qui va alimenter la clause where avant compactage
  def where_time_tests
    arr = Array.new
    created_after.nil?  || arr << "created_at > #{created_after}"
    created_before.nil? || arr << "created_at < #{created_before}"
    updated_after.nil?  || arr << "updated_at > #{updated_after}"
    updated_before.nil? || arr << "updated_at < #{updated_before}"
    return arr
  end

  # Pour ajouter à la désignation de l'objet
  # Ajoute p.e. le texte " créé avant le <date>"
  def times_for_designation
    str = ''
    created_after.nil?  || str << " #{mess_created_after}"
    created_before.nil? || str << " #{mess_created_before}"
    updated_after.nil?  || str << " #{mess_updated_after}"
    updated_before.nil? || str << " #{mess_updated_before}"
    return str.strip
  end


  def mess_created_after
    "créé après le #{jouretheure created_after}"
  end
  def mess_created_before
    "créé avant le #{jouretheure created_before}"
  end
  def mess_updated_after
    "actualisé après le #{jouretheure updated_after}"
  end
  def mess_updated_before
    "actualisé avant le #{jouretheure updated_before}"
  end

  # Retourne la date humaine avec l'heure de +time+ (secondes)
  def jouretheure time
    time.as_human_date(true, true, ' ', 'à')
  end

end
