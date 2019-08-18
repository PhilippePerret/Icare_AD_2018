# encoding: UTF-8
# encoding: UTF-8
class Bureau
class << self

  # Méthode principale construisant le widget de l'échéance du module
  # si l'icarien est actif
  def _fs_etape_courante
    user.actif? || (return '')
    (
      'Étape courante'.in_div(class: 'titre') +
      ligne_etape_module        +
      ligne_numero_etape_module +
      ligne_index_etapes        +
      ligne_echeance_etape        +
      ligne_nombre_jours_restants +
      ligne_change_echeance
    ).in_fieldset(id: 'fs_etape_courante')
  end

  def travail_etape_sent?
    @travail_etape_sent = icetp.status > 1 if @travail_etape_sent === nil
    @travail_etape_sent
  end

  # ---------------------------------------------------------------------
  #   Sous-méthodes d'helper
  # ---------------------------------------------------------------------

  def ligne_etape_module
    line_info 'titre', absetp.titre
  end
  def ligne_numero_etape_module
    line_info 'numéro', absetp.numero, 'right'
  end

  def ligne_index_etapes
    nbetape = dbtable_icetapes.count(where: {icmodule_id: icmod.id})
    sup = nbetape > 1 ? 'e' : 'ère'
    line_info 'index', "#{nbetape}<sup>#{sup}</sup> étape", 'right'
  end

  def ligne_echeance_etape
    if travail_etape_sent?
      # Quand le travail a été envoyé, on profite de cette ligne pour afficher
      line_info 'travail rendu le', time_remise_travail.as_human_date(false, true, nil, 'à'), 'cool right'
    else
      line_info 'échéance', icetp.expected_end.as_human_date(true, true, nil, 'à'), 'right'
    end
  end

  # Pour connaitre la date de remise du travail, il suffit de
  # prendre le created_at du premier document, s'il existe.
  # RETURN Le nombre de secondes
  def time_remise_travail
    icetp.documents.nil_if_empty != nil || (return '?')
    first_doc_id = icetp.documents.split(' ').first.to_i
    dd = dbtable_icdocuments.get(first_doc_id, colonnes:[:created_at, :time_original])
    dd[:created_at] || dd[:time_original]
  end

  def ligne_nombre_jours_restants
    travail_etape_sent? && (return '')
    nbj = (icetp.expected_end - Time.now.to_i)/1.day + 1
    # nbj = -10
    lib, css =
      if nbj > 3
        ['reste', 'cool']
      elsif nbj >= 0
        ['reste', 'near']
      else
        nbj = -nbj
        ['dépassement   ', 'warning']
      end
    s = nbj > 1 ? 's' : ''
    line_info lib, "#{nbj} jour#{s}", "#{css} right"
  end
  def ligne_change_echeance
    travail_etape_sent? && (return '')
    line_info( 'repousser au', '') +
    line_info( '', form_change_echeance, 'right')
  end


  # Formulaire de changement d'échéance
  #
  # C'est un menu permettant à l'icarien de repousser son échéance ou
  # de la rapprocher. Il peut la rapprocher jusqu'à aujourd'hui et la
  # repousser jusqu'à un mois depuis maintenant.
  #
  def form_change_echeance
    (
      menu_jours_echeance +
      'expected_end'.in_hidden(name: 'property[name]', id: 'property_name') +
      'Integer'.in_hidden(name: 'property[type]', id: 'property_type') +
      'Appliquer cette échéance'.in_submit(class: 'small')
    ).in_form(action: "ic_etape/#{icetp.id}/set", id: 'form_echeance')
  end
  def menu_jours_echeance
    echoue =
      if icetp.expected_end > NOW
        icetp.expected_end
      else
        NOW
      end
    last_day = echoue + 30.days
    ijour = 0
    options = Array.new
    while (jour = Time.now.to_i + (ijour += 1).days) < last_day
      jour = Time.now.to_i + ijour.days
      jour_time  = Time.at(jour)
      jour_matin = Time.new(jour_time.year, jour_time.month, jour_time.day).to_i
      doption = {value: jour}
      jour_matin < echoue && (jour_matin + 1.day) > echoue && begin
        doption.merge!(selected: true, class: 'exergue')
      end
      options << jour.as_human_date(false, false, ' ').in_option(doption)
    end
    options.join.in_select(id: 'new_echeance', name: 'property[value]')
  end
end#<< self
end #/Bureau

# <%=
#   real_n = Time.now
#   now = Time.new(real_n.year, real_n.month, real_n.day).to_i
#   echeance_found = false # pour sélectionner l'échéance courante
#   30.times.collect do |itime|
#     nowplus = now + itime.days
#     nowplus_h = nowplus.as_human_date(long = false)
#     if echeance_found == false && nowplus > current_etape.echeance
#       echeance_found = true
#       [nowplus, nowplus_h, true]
#     else
#       [nowplus, nowplus_h]
#     end
#   end.in_select(name: 'new_echeance')
#   %>
# <%= "Appliquer cette échéance".in_submit(class: 'btn tiny') %>
# <%= link_aide("?", {rubrique: 'bureau', sous_rubrique: 'echeance', class: 'cadre'}) %>
