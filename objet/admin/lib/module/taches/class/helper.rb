# encoding: UTF-8
# raise_unless_admin
class Admin
class Taches
class << self

  # Retourne la pastille à coller en haut de page indiquant à
  # un administrateur le nombre de tâches qu'il a à faire
  def pastille_taches_administrator

    todolist  = new(admin_id: user.id)
    nombre_taches_overl = 0
    nombre_taches_today = 0
    nombre_taches_later = 0
    nombre_taches_nodat = 0
    taches    = todolist.taches
    nombre_taches = taches.count

    # S'il n'y a aucune tache on peut retourner un string vide, ce
    # qui signifie qu'aucune pastille ne sera affichée.
    return "" if nombre_taches == 0
    taches.each do |itache|
      if itache.echeance.nil?
        nombre_taches_nodat += 1
      elsif itache.echeance < Today.start
        nombre_taches_overl += 1
      elsif itache.today?
        nombre_taches_today += 1
      else
        nombre_taches_later += 1
      end
    end

    # La couleur de la pastille va dépendre de l'échéance
    bkg = if nombre_taches_overl > 0
      'red'
    elsif nombre_taches_today > 0
      'green'
    else
      'blue'
    end

    taches = Array::new
    taches << "#{tache_s nombre_taches_overl} en retard.".in_span(class:'red') if nombre_taches_overl > 0
    taches << (nombre_taches_today > 0 ? "#{tache_s nombre_taches_today} à effectuer aujourd'hui." : "Aucune tâche à effectuer aujourd'hui.")
    taches << "#{tache_s nombre_taches_later} à effectuer plus tard." if nombre_taches_later > 0
    taches << "#{tache_s nombre_taches_nodat} sans échéance." if nombre_taches_nodat > 0

    data_pastille = {
      nombre:       nombre_taches,
      href:         "admin/taches",
      background:   bkg,
      title:        "Cliquer ci-dessus pour voir la liste complète.",
      taches:       taches
    }

    site.require_module('Pastille')
    ipastille = SiteHtml::Pastille::new
    ipastille.set data_pastille
    ipastille.output


  end

  def tache_s nombre
    "#{nombre} tâche#{nombre > 1 ? 's' : ''}"
  end

end #/<<self
end #/Taches
end #/Admin
