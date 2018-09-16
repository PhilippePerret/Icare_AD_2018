# encoding: UTF-8
class Bureau
class << self

  # Instance de l'étape absolue
  def icetape     ; @icetape      ||= user.icetape        end
  def abs_current ; @abs_current  ||= icetape.abs_etape   end

  # Pour définir explicitement l'étape absolue, par exemple quand
  # c'est l'administrateur qui veut la voir, hors de toute étape
  # d'icarien.
  def abs_current= abscur
    @abs_current = abscur
  end
  def icetape= icetap
    @icetape = icetap
  end

  # = main =
  #
  # Méthode principale retournant le fieldset du travail complet.
  #
  def _section_current_work
    (
      liens_editions_if_admin       +
      div_titre_etape               +
      section_etape_objectifs       +
      section_etape_travail         +
      section_etape_travail_propre  +
      section_etape_liens           +
      section_etape_methode         +
      section_etape_mini_faq        +
      section_etape_qdd
    ).in_fieldset(id: 'current_etape_work', class: 'fs_etape_work')
  end

  def tit_section titre
    titre.in_div(class: 'titlesection')
  end

  def liens_editions_if_admin
    abs_current.liens_edit_if_admin.in_div(class: 'small right')
  end

  def div_titre_etape
    abs_current.titre.in_div(id: 'etape_titre')
  end

  def section_etape_objectifs
    (
      tit_section('Objectif') +
      abs_current.objectifs_formated
    ).in_section(id: 'section_etape_objectif', class: 'worksection')
  end

  def section_etape_travail
    (
      tit_section('Travail') +
      abs_current.travail_formated
    ).in_section(id: 'section_etape_travail', class: 'worksection')
  end

  # Note : seulement si c'est par un icetape que ce travail est
  # affiché.
  def section_etape_travail_propre
    (icetape && icetape.travail_propre) || (return '')
    (
      tit_section('Travail propre') +
      icetape.travail_propre_formated
    ).in_section(id: 'section_etape_travail_propre', class: 'worksection')
  end

  def section_etape_liens
    abs_current.liens || (return '')
    (
      tit_section('Liens') +
      abs_current.liens_formated
    ).in_section(id: 'section_etape_liens', class: 'worksection')
  end

  def section_etape_methode
    abs_current.methode || (return '')
    (
      tit_section('Méthode') +
      abs_current.methode_formated
    ).in_section(id: 'section_etape_methode', class: 'worksection')
  end

  def section_etape_mini_faq
    (
      tit_section('Mini-faq') +
      abs_current.minifaq_formated +
      AbsMinifaq.formulaire(abs_current)
    ).in_section(id: 'section_etape_mini_faq', class: 'worksection')
  end

  def section_etape_qdd
    (
      tit_section('Quai des docs') +
      abs_current.qdd_formated
    ).in_section(id: 'section_etape_qdd', class: 'worksection')
  end

end #/ << self
end #/ Bureau
