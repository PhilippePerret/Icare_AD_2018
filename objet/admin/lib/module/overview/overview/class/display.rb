# encoding: UTF-8
class Admin
class Overview
class << self

  def add_in_cal_data kdate, data
    @cal_data ||= Hash.new
    @cal_data.key?(kdate) || @cal_data.merge!(kdate => Array.new)
    @cal_data[kdate] << data

  end
  # = main =
  #
  # Méthode principale affichant l'aperçu de tous les icariens
  # en activité
  #
  def display
    # Pour mettre toutes les erreurs rencontrées
    @errors = Array.new
    analyse_situation

    # Le texte retourné
    # On construit la grille en mettant les étapes
    display_calendar +
    legende_calendrier +
    # page.separator(100) +
    'Aperçu par icarienne et icarien'.in_h3 +
    overview_textuel # un aperçu plus littéraire

  end
  # /display

  def analyse_situation


    # On relève les informations sur les icariens en consignant dans les
    # jours :
    #   - le début de l'étape
    #   - la fin attendue du travail (si étape status et < ???)
    #   - la fin attendue des commentaires (si status > ???)
    users_actifs.each do |huser|
      u = User.new(huser[:id])

      u.icmodule != nil || begin # au cas où…
        @errors << "L'user actif #{u.pseudo} (##{u.id}) à un icmodule à NIL…"
        next
      end

      u.icetape != nil || begin # au cas où…
        @errors << "L'user #{u.pseudo} (##{u.id}) à un icetape à NIL, alors qu'il/elle est marqué/e actif/ve"
        next
      end
      icetape = u.icetape

      # Paiement
      u.icmodule.next_paiement.nil? || begin
        key_paiement = inverse_date(Time.at(u.icmodule.next_paiement))
        add_in_cal_data(key_paiement, [:paiement, u])
      end

      # Étape
      statut_etape  = icetape.status
      start_date = Time.at(icetape.started_at)
      key_start = inverse_date(start_date)
      # Mettre dans la donnée du calendrier
      add_in_cal_data key_start, [:start, u]
      # Est-ce que c'est un travail qui est attendu ou un
      # commentaire.
      if statut_etape == 1
        # Travail attendu
        work_date = Time.at(icetape.expected_end)
        key_work = inverse_date(work_date)
        add_in_cal_data(key_work, [:work, u])
      elsif statut_etape > 1
        # Commentaires attendus
        if icetape.expected_comments.nil?
          # UNE ERREUR
          debug "# expected_comments NON DÉFINI (pour #{u.pseudo} ##{u.id})"
        else
          comments_date = Time.at(icetape.expected_comments)
          key_comments = inverse_date(comments_date)
          add_in_cal_data(key_comments, [:comments, u])
        end
      end
    end

  end
  # /analyse_situation

  def inverse_date d
    y = d.year
    m = d.month.to_s.rjust(2,'0')
    d = d.day.to_s.rjust(2,'0')
    "#{y}#{m}#{d}"
  end

  # Affiche la portion de calendrier de trois mois qui
  # permet de visualiser les icariens
  # ET insert les icariens dans les jours
  #
  def display_calendar
    now   = Time.now
    key_today = inverse_date(now)
    t = String.new
    t << '<div class= "calrow">'
    cal_start = now.to_i - 30.days
    93.times do |njour|
      thisdate = Time.at(cal_start + njour.days)
      key_this_date = inverse_date(thisdate)
      overrun = key_this_date < key_today
      content =
        if @cal_data.key?(key_this_date)
          # Pour régler la hauteur
          nombre_elements = @cal_data[key_this_date].count
          top, top_pseudo, left_pseudo =
            if nombre_elements == 1
              [3, -26, 2]
            else
              [-21, -10, 20]
            end
          @cal_data[key_this_date].collect do |arr|
            type, owner = arr
            # Pour signalier que le démarrage de l'étape
            # a commencé avant le début du calendrier courant
            farfromnow = owner.icetape.started_at < cal_start
            # Pour régler la hauteur
            # Pour régler la mark
            mark =
              (
                case type
                when :start     then 'D'
                when :work      then 'W'
                when :comments  then 'C'
                when :paiement  then 'P'
                end +
                mark_pseudo(owner, top_pseudo, left_pseudo, farfromnow) +
                carte_etape(type, owner, overrun, farfromnow)
              ).in_span(class: "calmark #{type}#{overrun && type != :start ? ' overrun' : ''}", style: "top:#{top}px;")
            top += 24
            mark
          end.join
        else
          ''
        end
      # debug "content : #{content.inspect}"
      if njour == 0
        t << "<div class='calmonth'>#{Fixnum::MOIS_LONG[thisdate.month]}</div>"
      end
      jour_courant = now.month == thisdate.month && now.day == thisdate.day

      classe_day = ['calday']
      false == jour_courant || classe_day << 'current'
      if thisdate.day == 1
        # On met la rangée pour le mois et on
        # commence une nouvelle rangée de jours
        t << '</div>'
        t << '<div class= "calrow">'
        t << "<div class='calmonth'>#{Fixnum::MOIS_LONG[thisdate.month]}</div>"
      elsif thisdate.day == 16
        # On commence simplement une nouvelle rangée
        t << '</div>'
        t << '<div class= "calrow">'
      end
      t << "<div class='#{classe_day.join(' ')}'>#{content}#{thisdate.day.to_s.in_span(class: 'markday')}</div>"
    end
    # /Fin de boucle sur ~ 93 jours
    t << '</div>' # pour fermer la rangée calrow
    t.in_div(class: 'cal')
  end
  # /display_calendar

  # Le pseudo de l'icarien/ne, au-dessus de la marque ronde
  def mark_pseudo u, top, left, farfromnow
    u.pseudo.in_span(class: "calpseudo#{farfromnow ? ' farfromnow' : ''}", style: "top:#{top}px;left:#{left}px")
  end
  # La carte de l'étape lorsque la mark d'opération est survolée (le
  # rond de couleur dans le calendrier)
  def carte_etape type, u, overrun, farformnow
    absetape = u.icetape.abs_etape
    (
      "#{u.pseudo} (##{u.id})".in_div(class: 'pseudo') +
      (
        "Module #{u.icmodule.abs_module.name}".in_div(class:'module') +
        "Étape #{absetape.numero} : #{absetape.titre}".in_div(class: 'etape') +
        "démarrée le #{u.icetape.started_at.as_human_date}".in_div(class: "etpstart#{farformnow ? ' farformnow' : '' }")
      ).in_div(class: 'infoscard') +
      (
        case type
        when :start     then 'Démarrage de l’étape'
        when :work      then 'Remise du travail'
        when :comments  then 'Remise des commentaires'
        when :paiement  then 'Paiement'
        end + ' le ' +
        case type
        when :start     then u.icetape.started_at
        when :work      then u.icetape.expected_end
        when :comments  then u.icetape.expected_comments
        when :paiement  then u.icmodule.next_paiement
        end.as_human_date
      ).in_div(class: "opecard#{overrun ? ' overrun' : ''}")
    ).in_div(class: 'etpcard')
  end

  def overview_textuel
    users_actifs.collect do |huser|
      begin
        User.new(huser[:id]).overview
      rescue Exception => e
        debug e
        ''
      end
    end.join('').in_div(class: 'users_overview')
  end

  # Retourn la liste des Hash de données des icariens
  # actifs.
  def users_actifs
    @users_actifs ||= begin
      drequest = {
        where:    'SUBSTRING(options,17,1) = "2"',
        colonnes: []
      }
      dbtable_users.select(drequest)
    end
  end


  def legende_calendrier
    <<-HTML
    <div id="legend_cal">
      <div><span class="calmark start">D</span> = démarrage de l'étape (noter que si ce démarrage est antérieur à la première date, il n'apparait pas, mais il est inscrit sur la fiche). <span class="calmark work">W</span> = travail à rendre. <span class="calmark comments">C</span> = commentaires à rendre, <span class="calmark paiement">P</span> = paiement. </div>
      <div>
        <span class="calmark overrun">W</span> <span class="calmark overrun">C</span> <span class="calmark overrun">P</span>
        Tous les cercles rouges sont des dépassements d'échéance.
      </div>
      <div>
        Quand un pseudo est précédé de 🔔, cela signifie que son étape a démarré avant la première date de la portion de calendrier courant. Peut-être a-t-il trop repoussé ses échéances…
      </div>
    </div>
    HTML
  end

end #/<< self
end #/Overview
end #/Admin
