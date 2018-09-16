# encoding: UTF-8
=begin

  Méthodes d'helper pour l'affiche de l'aperçu de l'icarien

=end
class User

  # = main =
  #
  # Méthode principale
  def overview
    # Pour mettre les erreurs et afficher les liens utiles
    @errors_overview = Array.new
    (
      pseudo.capitalize.in_span(class: 'pseudo') +
      div_module_etape +
      expected_paiement
    ).in_div(class: 'user_overview')

  end

  def absetape
    @absetape ||= begin
      site.require_objet 'abs_etape'
      icetape.abs_etape
    end
  end
  def div_module_etape
    (
      icmodule.abs_module.name.in_span(class: 'module') +
      "#{absetape.numero}. #{absetape.titre}".in_span(class: 'etape') +
      div_start_end_etape
    ).in_div(class: 'moduleetape')
  end


  def div_start_end_etape
    if icetape.expected_end < NOW
      @errors_overview << :echeance
    end
    m = "#{as_date icetape.started_at} → #{as_date icetape.expected_end, check: true}"
    m.in_div(class: 'startendetape')
  end

  def as_date seconds, options = nil
    css = ''
    options.nil? || begin
      if options[:check] && seconds < NOW
        css = 'warning bold'
      else
        css = 'green'
      end
    end
    seconds.as_human_date(false).in_span(class: "date #{css}".strip)
  end

  # Si nécessaire, la date de prochain paiement, avec possibilité
  # de lui envoyer un rappel
  def expected_paiement
    icmodule.next_paiement != nil || (return '')
    classe_paiement =
      if icmodule.next_paiement < Time.now.to_i
        @errors_overview << :paiement
        'warning'
      else
        'blue'
      end
    "Paiement : #{as_date icmodule.next_paiement, check: true}".in_span(class: "paiement #{classe_paiement}")
  end

end
