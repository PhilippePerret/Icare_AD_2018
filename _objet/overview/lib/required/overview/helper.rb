# encoding: UTF-8
class Atelier
class Overview

  DATA_LINKS_OVERVIEW = {
    home:         'Présentation de l’atelier',
    reussites:    'Belles réussites d’icarien.ne.s',
    parcours:     'Parcours fictif de 3 icarien.ne.s',
    raisons:      '10 bonnes raisons de choisir l’atelier',
    temoignages:  'Les témoignages d’ancien.ne.s icarien.ne.s',
    nom_atelier:  'Le nom de l’atelier',
    stats:        'L’atelier en chiffres'
  }

class << self

  # Encart qui affiche les menus pour rejoindre les différentes
  # parties de la présentation
  def quicklinks
    menu_links_overview.in_ul(class: 'nav cadre no-puces inline fright air-around')
  end

  # La liste des liens vers les autres parties, mais en bas
  # de page
  #
  def quicklinks_bottom
    'En apprendre encore plus sur l’atelier Icare ?'.in_h3 +
    menu_links_overview.in_ul(class: 'nav no-puces')
  end

  def menu_links_overview
    DATA_LINKS_OVERVIEW.keys.collect do |ovw_id|
      classecss = ovw_id == current_section ? 'selected' : nil
      link_overview(ovw_id).in_li(class: "nav-item")
    end.compact.join
  end

  def link_overview overview_id = :home
    DATA_LINKS_OVERVIEW[overview_id].in_a(href: "overview/#{overview_id}")
  end
end #/<< self
end #/Overview
end #/Atelier
