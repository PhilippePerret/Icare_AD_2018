# encoding: UTF-8
class Admin
class Paiements

  def output
    site.require_objet 'ic_module'

    @montant_total = 0
    @paiements_modules_suivis = Array.new
    @paiements_modules_apprentissage = Array.new

    c = String.new
    # On fait d'abord les lignes qui vont permettre
    # de récupérer les données
    c << line_paiements
    c << lines_par_payeur
    # On ajoute ensuite le libellé et le récapitulatif
    c = libelle + recapitulatif + c

    Admin::Paiements.options[:hide_form] = true
    Admin::Paiements.content << c
  end

  def libelle
    @libelle ||= begin
      "Paiements effectués<br>du #{from_date_str}<br>au #{to_date_str} (non compris)".in_h4
    end
  end

  def recapitulatif
    (
      montant_total +
      montant_total_modules_suivis +
      montant_total_modules_apprentissage +
      nombre_paiements +
      nombre_de_mois +
      moyenne_par_mois
    ).in_div(class: 'lines_paiements').in_div
  end
  def montant_total
    libval('<b>Montant total</b>', "<b>#{@montant_total} €</b>")
  end
  def moyenne_par_mois
    libval('Moyenne par mois', "#{@montant_total / nombre_mois} €")
  end
  def montant_total_modules_suivis
    m = 0
    @paiements_modules_suivis.each do |hpaie|
      m += hpaie[:montant]
    end
    libval('Modules de suivi de projet', "#{m} €")
  end
  def montant_total_modules_apprentissage
    m = 0
    @paiements_modules_apprentissage.each do |hpaie|
      m += hpaie[:montant]
    end
    libval('Modules d’apprentissage', "#{m} €")
  end
  def nombre_paiements
    libval('Nombre de paiements', all_paiements.count)
  end
  def nombre_de_mois
    libval('Nombre de mois', nombre_mois)
  end

  def libval lib, val
    (
      lib     .in_span(class: 'libelle') +
      val.to_s.in_span(class: 'value')
    ).in_div(class: 'libval')
  end

  def all_paiements
    @all_paiements ||= begin
      get_paiements(from_time, to_time)
    end
  end

  def line_paiements
    'Tous les paiements'.in_h3 +
    (
      line_libelles_par_paiement +
      all_paiements.collect do |hpaiement|
        # debug "#{hpaiement.inspect}"
        user_id = hpaiement[:user_id]
        payeurs.key?(user_id) || begin
          @payeurs.merge!(user_id => {user: User.get(user_id), paiements: [], total: 0})
        end
        @payeurs[user_id][:paiements] << hpaiement
        @payeurs[user_id][:total] += hpaiement[:montant]
        line_paiement(hpaiement)
      end.join('')
    ).in_div(class: 'lines_paiements')
  end

  def lines_par_payeur
    'Par icarien'.in_h3 +
    (
      line_libelles_par_payeur +
      payeurs.sort_by{|uid, h| -h[:total]}.collect do |uid, hpayeur|
        hpayeur.merge!(
          pseudo:           hpayeur[:user].pseudo,
          montant_total:    hpayeur[:total],
          nombre_montants:  hpayeur[:paiements].count
        )
        template_line_payeur % hpayeur
      end.join('')
    ).in_div(class: 'lines_paiements')
  end
  def line_libelles_par_payeur
    (
      'Pseudo'.in_span(class: 'pseudo')+
      'Total'.in_span(class: 'total')+
      'Nb paiements'.in_span(class: 'nombre')
    ).in_div(class:'line_payeur libelles')
  end
  def template_line_payeur
    (
      '%{pseudo}'.in_span(class: 'pseudo') +
      '%{montant_total} €'.in_span(class: 'total') +
      '%{nombre_montants}'.in_span(class: 'nombre')
    ).in_div(class: 'line_payeur')
  end


  # Retourne une ligne pour l'affichage du paiement de
  # données +hdata+
  # On profite de cette méthode pour mémoriser aussi les
  # paiements qui sont effectués sur des modules de suivi de
  # projet ou des modules d'apprentissage, grâce à la donnée
  # `:ic_module_id`
  def line_paiement hdata
    user    = User.get(hdata[:user_id])
    umodule = IcModule.new(hdata[:icmodule_id])
    if umodule.type_suivi?
      @paiements_modules_suivis << hdata
    else
      @paiements_modules_apprentissage << hdata
    end
    # MONTANT TOTAL CALCULÉ
    @montant_total += hdata[:montant]
    hdata.merge!(
      pseudo:   user.pseudo,
      date:     Time.at(hdata[:created_at]).strftime('%d %m %Y'),
      suivi:    (umodule.type_suivi? ? 'OUI' : 'NON')
    )
    template_line_paiement % hdata
  end

  def line_libelles_par_paiement
    (
      'id'.in_span(class: 'id') +
      'montant'.in_span(class: 'montant') +
      'icarien/ne'.in_span(class: 'icarien') +
      'date'.in_span(class: 'date') +
      'suivi ?'.in_span(class: 'suivi')
    ).in_div(class: 'line_paiement libelles')
  end
  def template_line_paiement
    @template_line_paiement ||= begin
      (
        '#%{id}'.in_span(class: 'id') +
        '%{montant} €'.in_span(class: 'montant') +
        '%{pseudo} (#%{user_id})'.in_span(class: 'icarien') +
        '%{date}'.in_span(class: 'date') +
        '%{suivi}'.in_span(class: 'suivi')
      ).in_div(class: 'line_paiement')
    end
  end

end #/Paiements
end #/Admin
