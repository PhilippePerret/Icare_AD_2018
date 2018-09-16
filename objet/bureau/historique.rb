# encoding: UTF-8
=begin

  Module pour l'historique de l'icarien

=end
site.require_objet 'ic_module'
class IcModule

  # = main =
  #
  # Affichage du module sous forme d'historique
  def as_historique
    (
      # # Ligne avec ID
      # "[##{id}] module #{abs_module.name}".in_div(class: 'titre') +
      "module #{abs_module.name}".in_div(class: 'titre') +
      dates_module.in_span(class: 'dates') +
      listing_etapes
    ).in_div(class:'icmodule')
  end

  def dates_module
    debut = started_at.as_human_date(true, false)
    fin   = ended_at.nil? ? '- en cours -' : ended_at.as_human_date
    "#{'Du'.in_span(class: 'libelle')}#{debut} #{'au'.in_span(class: 'libelle')}#{fin}"
  end

  def listing_etapes
    etapes.collect do |etape|
      absetape = etape.abs_etape
      (
        # # Ligne avec ID
        (absetape.lien_voir_intitule).in_div(class: 'etpbtns') +
        # "[##{etape.id}] #{absetape.numero} #{absetape.titre} - #{etape.started_at.as_human_date}"
        absetape.numero.to_s.in_span(class: 'etpnum') +
        absetape.titre.in_span(class: 'etptit')  +
        etape.started_at.as_human_date(false).in_span(class:'etpdate')
      ).in_div(class: 'etape')
    end.join.in_div(class: 'etape')
  end

  def etapes
    @etapes ||= begin
      site.require_objet 'ic_etape'
      drequest = {
        where:    {icmodule_id: self.id},
        order:    'started_at ASC',
        colonnes: []
      }
      dbtable_icetapes.select(drequest).collect do |hetape|
        IcModule::IcEtape.new(hetape[:id])
      end
    end
  end

end
class AbsModule
  class AbsEtape

    # Le lien pour lire l'intitulé de l'étape
    def lien_voir_intitule
      'relire'.in_a(href: "abs_etape/#{id}/show", target: :new)
    end

  end #/AbsEtape
end #/AbsModule
