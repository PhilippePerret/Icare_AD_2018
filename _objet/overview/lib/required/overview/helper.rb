# encoding: UTF-8
class Atelier
class Overview
class << self

  # Encart qui affiche les menus pour rejoindre les différentes
  # parties de la présentation
  def quicklinks
    menu_links_overview.in_ul(class: 'nav flex-column offset-md-7 col-md-5 cadre mb-5')
  end

  # La liste des liens vers les autres parties, mais en bas
  # de page
  #
  def quicklinks_bottom
    'En apprendre encore plus sur l’atelier Icare ?'.in_h3 +
    menu_links_overview.in_ul(class: 'nav flex-column')
  end

  def menu_links_overview
    [:home, :reussites, :parcours, :raisons, :temoignages, :stats
    ].collect do |ovw_id|
      classecss = ovw_id == current_section ? 'selected' : nil
      link_overview(ovw_id).in_li(class: "nav-item")
    end.compact.join
  end

  def link_overview overview_id = :home
    case overview_id
    when :home        then 'Présentation de l’atelier'
    when :reussites   then 'Belles réussites d’icarien(ne)s'
    when :parcours    then 'Parcours fictif de 3 icarien(ne)s'
    when :raisons     then '10 bonnes raisons de choisir l’atelier'
    when :temoignages then 'Témoignages'
    when :stats       then 'L’atelier en chiffres'
    end.in_a(href: "overview/#{overview_id}")
  end
end #/<< self
end #/Overview
end #/Atelier
