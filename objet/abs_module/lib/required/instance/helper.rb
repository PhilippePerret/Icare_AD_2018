# encoding: UTF-8
class AbsModule

  def as_li
    (
      bouton_commande_module +
      module_name_formated  +
      (
        lien_open_short_description +
        tarif_formated        +
        duree_formated        +
        div_explications
      ).in_div(class: 'information')
    ).in_li(id: "absmodule-#{id}", class: 'absmodule')
  end

  def bouton_commande_module titre = 'Postuler'
    # Direction différente en fonction du fait que l'user est
    # inscrit ou non
    href = (user.identified? ? 'abs_module/command' : 'user/signup') + "?mid=#{id}"
    titre.in_a(href: href, class: 'btn_command')
  end
  def module_name_formated
    "Module “#{name}”".in_span(class: 'name')
  end
  def duree_formated
    if nombre_jours.nil?
      'durée indéterminée'
    elsif nombre_jours < 70
      '2 mois (extensibles)'
    elsif nombre_jours < 100
      '3 mois (extensibles)'
    elsif nombre_jours < 200
      '4 mois'
    else
      nombre_jours.to_s
    end.in_span(class: 'duree')
  end

  def tarif_formated
    t = "#{tarif} €"
    type_suivi? && t << " / mois"
    t.in_span(class: 'tarif')
  end

  def div_explications
    (
      short_description +
      lien_open_description_longue +
      div_explication_longue +
      bouton_commande_module('Postuler pour ce module').in_div(class: 'btn_bottom')
    ).in_div(id: "div_shortdesc-#{id}", class: 'shortdesc', style: 'display:none')
  end
  def div_explication_longue
    long_description.in_div(class: 'longdesc', id: "div_longdesc-#{id}", style: 'display:none')
  end

  def lien_open_short_description
    'Détail'.in_a(class: 'detail', onclick: "$('div#div_shortdesc-#{id}').toggle()")
  end
  def lien_open_description_longue
    'Encore plus de détail'.in_a(class: 'detail_plus', onclick: "$('div#div_longdesc-#{id}').toggle()")
  end

end #/AbsModule
