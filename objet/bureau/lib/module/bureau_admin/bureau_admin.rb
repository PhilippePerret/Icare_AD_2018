# encoding: UTF-8
class Bureau
class << self
  def _section_administrateur
    (
      liens_editions
    ).in_section(id: 'bureau_administrateur')
  end
  def liens_editions
    (
      'Bases de données'.in_h3 +
      'BASES DE DONNÉES'.in_a(href: 'database/edit').in_div +
      'WATCHERS'.in_a(href: 'watcher/edit').in_div +

      'Gestion Icariens'.in_h3 +
      'Aperçu général'.in_a(href: 'admin/overview').in_div +
      'Opérations ICARIEN/S…'.in_a(href: 'admin/users').in_div +
      'Mailing list'.in_a(href: 'admin/mailing').in_div +
      'Visiter le site comme…'.in_a(href: 'admin/visit_as').in_div +
      'Paiements'.in_a(href: 'admin/paiements').in_div +
      'Listing des icariens'.in_a(href: 'icarien/list').in_div +

      'Actualisations'.in_h3 +
      bouton_check_synchro +

      'Modules d’apprentissage'.in_h3 +
      boutons_modules_apprentissage +
      boutons_edition_etapes_modules +
      boutons_edition_travaux_types +

      'Tests divers'.in_h3 +
      bouton_test_travaux +

      'Divers'.in_h3 +

      'Opérations sensibles'.in_h3 +
      bouton_erase_user_everywhere
    ).in_div
  end
  def boutons_modules_apprentissage
    # if OFFLINE
      'Modules d’apprentissage'.in_a(href: 'abs_module/edit').in_div
    # else
    #   ''
    # end
  end
  def boutons_edition_etapes_modules
    'Édition des étapes'.in_a(href: 'abs_etape/1/edit').in_div
    # OFFLINE ? 'Édition des étapes'.in_a(href: 'abs_etape/1/edit').in_div : ''
  end
  def boutons_edition_travaux_types
    'Édition des travaux-types'.in_a(href: 'abs_travail_type/1/edit').in_div
  end

  def bouton_check_synchro
    OFFLINE || (return '')
    'Check SYNCHRO'.in_a(href: 'admin/dashboard?opadmin=check_synchro').in_div
  end
  def bouton_erase_user_everywhere
    OFFLINE || (return '')
    'ERASE USER (ID dans admin/dashboard)'.in_a(class: 'warning', href: 'admin/dashboard?opadmin=erase_user_test').in_div
  end
  def bouton_test_travaux
    OFFLINE || (return '')
    'Test travaux des étapes et des travaux-types'.in_a(href: 'admin/dashboard?opadmin=check_all_deserbage_travaux').in_div
  end
end #/<< self
end #/Bureau
