# encoding: UTF-8
class AbsModule

  def as_li
    (
      module_name_formated.in_div(class:'row')  +

      (
        duree_formated.in_div(class: 'col duree') +
        tarif_formated.in_div(class: 'col') +
        lien_open_short_description.in_div(class: 'col') +
        bouton_commande_module.in_div(class: 'col')
      ).in_div(class: 'row') +

      div_explications.in_div(class: 'row')

    ).in_div(class: 'absmodule')
    # (
    #
    #   bouton_commande_module +
    #   (
    #     lien_open_short_description +
    #     div_explications
    #   ).in_div(class: 'information')
    # ).in_div(id: "absmodule-#{id}", class: 'row')
  end

  def bouton_commande_module titre = 'Postuler'
    # Direction différente en fonction du fait que l'user est
    # inscrit ou non
    href = (user.identified? ? 'abs_module/command' : 'user/signup') + "?mid=#{id}"
    titre.in_a(href: href, class: 'btn btn-primary')
  end
  def module_name_formated
    "Module “#{name}”".in_h4
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
    end
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
      div_explication_longue
    ).in_div(id: "div_shortdesc-#{id}", class: 'ml-5 shortdesc', style: 'display:none')
  end
  def div_explication_longue
    (
      long_description+
      bouton_commande_module('Postuler pour ce module').in_div(class: 'btn btn-primary')
    ).in_div(class: 'ml-5 longdesc', id: "div_longdesc-#{id}", style: 'display:none')
  end

  def lien_open_short_description
    'Détail'.in_a(class: 'detail', onclick: "$('div#div_shortdesc-#{id}').toggle()")
  end
  def lien_open_description_longue
    'Encore plus de détail'.in_a(class: 'detail_plus', onclick: "$('div#div_longdesc-#{id}').toggle()")
  end

end #/AbsModule
