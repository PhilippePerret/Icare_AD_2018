#!/usr/bin/env ruby
# encoding: UTF-8

class Cron

# Pour appeler le processus par le cron
# Noter qu'il est appelé toutes les heures, qu'il faut donc tester
# pour voir si c'est bien l'heure de l'envoi.
#
def _mail_activites
  REF_LOG_SUIVI.write " -> cron._mail_activites\n"
  Cron::Activites.mail_activites
  if Time.now.saturday? && Time.now.hour == Cron::Activites::MAIL_ACTIVITES_HOUR
    is_mail_hebdomadaire = true
    Cron::Activites.mail_activites
  end
  REF_LOG_SUIVI.write " <- /cron._mail_activites\n"
end

class Activites

  MAIL_ACTIVITES_HOUR = 1

  # Les mails à retirer des envois, pour différentes raisons à commencer
  # par le fait que l'adresse n'existe plus.
  MAILS_OUT = [
    'domideso@hotmail.fr', 'rocha_dilma@hotmail.com',
    'mahidalila@aol.com'
  ]

class << self

  # Retourne TRUE si c'est pour le mail hebdomadaire
  attr_accessor :is_mail_hebdomadaire
  def mail_hebdomadaire?
    self.is_mail_hebdomadaire
  end

  # Cette méthode retourne true s'il y a des activités de la
  # veille qui n'ont pas été envoyées. Cela se voit si :
  #   1/ il existe des activités non envoyées
  #   2/ certaines de ces activités ont une date plus vieille
  #      d'un jour.
  def actualites_non_envoyees?
    dernieres_activites.count > 0
  end

  # = main =
  #
  # Méthode principale qui envoie les mails d'activité à tous les
  # icariens qui en ont fait la demande et tous les actifs.
  #
  # C'est un envoi du mail quotifien ou du mail hebdomadaire en fonction
  # du jour.
  #
  # Noter que les librairies du site sont chargées, dans la nouvelle
  # version du cron.
  #
  def mail_activites
    REF_LOG_SUIVI.write "   -> Cron::Activites::mail_activites…\n"
    reset
    if mail_hebdomadaire?
      REF_LOG_SUIVI.write "     Envoi du mail hebdomadaire nécessaire\n"
      log "<hr />"
      log '---> Envoi du mail HEBDOMADAIRE', {time: true}
    elsif actualites_non_envoyees?
      REF_LOG_SUIVI.write "     Il existe des mails d'activités de la veille non envoyés.\n"
      REF_LOG_SUIVI.write "     Je poursuis l'opération pour envoyer ces actualités.\n"
    elsif Time.now.hour == MAIL_ACTIVITES_HOUR
      REF_LOG_SUIVI.write "     Envoi des mails d'activités de la veille\n"
      log "<hr />"
      log "---> Envoi des mails d'actualite de la veille", {time: true}
    else
      # Si ça n'est pas l'heure
      REF_LOG_SUIVI.write "     Pas l'heure d'envoi des mails d'activité\n"
      REF_LOG_SUIVI.write "   <- /Activites::mail_activites\n"
      return
    end

    # S'il n'y a aucune actualité trouvée pour la veille, on peut
    # s'en retourner aussitôt
    if dernieres_activites.empty?
      REF_LOG_SUIVI.write "     Aucune activité trouvée\n"
      REF_LOG_SUIVI.write "   <- /Activites::mail_activites\n"
      log '= Aucune actualite trouvée.'
      return
    end

    if mode_test?
      REF_LOG_SUIVI.write "     MODE TEST\n"
      log "MODE TEST --- Les mails ne seront pas vraiment envoyes"
    end

    log "*** ENVOI DES MESSAGES D'ACTUALITE ***", {time: true}
    destinataires.count > 0 || begin
      log "Aucun destinataire trouvé"
      REF_LOG_SUIVI.write "     Aucun destinataire trouvé (stop now)\n"
      REF_LOG_SUIVI.write "   <- /Activites::mail_activites\n"
      return
    end

    # ----------------------------
    # BOUCLE D'ENVOI DES MESSAGES
    # ----------------------------
    # log "- POUR LE MOMENT, LES MAILS NE SONT ENVOYÉS QU'À PHIL"
    # cf. def destinataires ci-dessous
    REF_LOG_SUIVI.write "     *** Boucle d'envoi des mails… "
    nombre_mails = 0
    nombre_destinataires = destinataires.count
    destinataires.each do |u|
      site.mails_out.include?(u.mail) && next
      resultat = send_mail_to u
      if resultat === true
        log "--- Message envoyé à #{u.pseudo} (#{u.mail})"
        nombre_mails += 1
      else
        debug resultat
        log "--# Erreur avec #{u.pseudo} (#{u.mail}) : #{resultat.message}"
      end
    end
    REF_LOG_SUIVI.write "OK (#{nombre_mails} mails envoyés sur #{nombre_destinataires} destinataires)\n"

  rescue Exception => e
    REF_LOG_SUIVI.write "ERROR (#{e.message})"
    debug e
    mess_err = e.message + "\n\n" + e.backtrace.join("\n")
    log "### Une erreur s'est produite : #{mess_err}"
    false
  else
    # Tout s'est bien passé, on marque que les actualités ont
    # été envoyées aux users
    mail_hebdomadaire? || mark_activites_envoyees
    true
  end

  def send_mail_to u
    data_mail = {
      subject:   subject_of_mail,
      message:   (message_template % {pseudo: u.pseudo}).force_encoding('utf-8'),
      formated:  true
    }
    return u.send_mail(data_mail)
  end

  def subject_of_mail
    @subject_of_mail ||= begin
      if mail_hebdomadaire?
        'Activités de la semaine'
      else
        'Dernières actualités de l’atelier Icare'
      end
    end
  end

  # On marque les activités envoyées
  def mark_activites_envoyees
    actu_ids = dernieres_activites.collect{|h| h[:id]}.join(', ')
    dbtable_activites.update({where: "id IN (#{actu_ids})"}, {status: 2})
  rescue Exception => e
    debug e
    log "### ERREUR en passant le statut des actualités à 2 : #{e.message} (backtrace dans le fichier débug)"
  else
    log "-- Activités #{actu_ids} marquées envoyées par mail quotidien"
  end

  # Raccourci pour savoir si on est en mode test
  def mode_test?; cron.mode_test? end


  # Retourne la liste {Array} des {Hash} de données des icariens qui
  # veulent ou qui doivent recevoir les mails d'activité
  #
  def destinataires
    @destinataires ||= begin
      whereclause = Array.new
      whereclause << "SUBSTRING(options,4,1) = '0'"   # pas détruit
      if mail_hebdomadaire?
        whereclause << "( SUBSTRING(options,18,1) = '2' OR SUBSTRING(options,18,1) = '3' )"  # choix hebdo
      else
        whereclause << "( SUBSTRING(options,18,1) = '0' OR SUBSTRING(options,18,1) = '3' )"  # actif ou mail quotidien
      end
      whereclause = whereclause.join(' AND ')
      dreq = {where: whereclause, colonnes: [:mail]}
      dbtable_users.select(dreq).collect do |hu|
        MAILS_OUT.include?(hu[:mail]) && next
        User.new(hu[:id])
      end.compact
      # Pour envoyer seulement à Phil et Marion
      # [ User.new(1), User.new(2) ]
    end
  end

  # ---------------------------------------------------------------------
  #
  #       MÉTHODES POUR LES ACTUALITÉS
  #
  # ---------------------------------------------------------------------

  # Retourne les actualités de la veille, sous forme de Array
  # En mode test, s'il n'y a aucune actualité, on en crée
  def dernieres_activites
    @dernieres_activites ||= begin
      cond_where =
        if mail_hebdomadaire?
          wed = hier[:end]
          "created_at > #{wed - 7.days} AND created_at < #{wed}"
        else
          "status = 1 AND created_at < #{hier[:end]}"
        end
      # cond_where = '1 = 1' # pour essai
      arr = dbtable_actualites.select(where:cond_where, order: 'created_at ASC')
      arr.sort_by { |ac| ac[:created_at] }
    end
  end

  # {String} Code HTML de la liste des actualités de la veille
  def listing_dernieres_activites
    "<div id='actualites'>#{actualites_as_li}</div>"
  end
  def actualites_as_li
    current_day = nil
    dernieres_activites.collect do |dactu|

      li = <<-HTML
      <div class='li_actu_mail'>
        <div class='actu_heure'>#{Time.at(dactu[:created_at]).strftime("%H:%M")}</div>
        <div class='actu_actu'>#{dactu[:message]}</div>
      </div>
      HTML
      # Ajouter le jour de l'actualité si c'est nécessaire
      # C'est déjà utile pour la veille du mail, mais ça peut être
      # aussi utile si plusieurs activités n'ont pas été annoncées avant
      if current_day != le_jour_de(dactu[:created_at])
        current_day = le_jour_de(dactu[:created_at])
        '<h4>' + current_day.as_human_date(true, false, ' ') + '</h4>'
      else
        ''
      end +
      li.gsub(/\n/,"")
    end.join("\n")
  end

  def le_jour_de time
    t = Time.at(time)
    Time.new(t.year, t.month, t.day, 0, 0, 0).to_i
  end
  # ---------------------------------------------------------------------
  #
  #         MÉTHODES POUR LE MESSAGE
  #
  # ---------------------------------------------------------------------

  # Le message template qui sera adapté à chaque icarien qui doit
  # recevoir les actualités
  def message_template
    @message_template ||= <<-EOC
#{stylesheet}
<p>Bonjour %{pseudo},</p>
<p>Trouvez ci-dessous la liste des dernières activités de l'atelier Icare.</p>
#{listing_dernieres_activites}
<hr style="margin-top:40px;" />
<p style="font-size:9pt;">Pour ne plus recevoir ces messages lorsque vous n'êtes pas icarien actif ou icarienne active, rejoignez <a href='http://www.atelier-icare.net/profil'>votre profil</a> et réglez vos préférences.</p>
<p>Bien &agrave; vous,</p>
      EOC
  end

  def stylesheet
    @stylesheet ||= <<-EOC
<style type="text/css">
h4{color:#008080;font-weight:normal;margin-bottom:8px}
.actu_heure {
color: #008080;
font-family:Georgia,Courier;
margin-right:1em;
font-size:0.95em;
}
div#actualites {
margin-left:2em;
font-size:0.85em;
}
div#actualites div.actu_heure {
display:inline-block;
width:80px;
}
div#actualites div.actu_actu {
}
</style>

    EOC
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def reset
    [
      :div_citation,
      :message_template,
      :destinataires,
      :dernieres_activites,
      :subject_of_mail
    ].each do |key|
      instance_variable_set("@#{key}", nil)
    end
  end

  # RETURN Un {Hash} contenant :start et :end, les dates
  # de debut et de fin de la veille
  #
  def hier
    @hier ||= begin
      n = Time.now
      today = Time.new(n.year, n.month, n.day)
      {
        start:  ( today - 1.day ).to_i,
        end:    today.to_i - 1
      }
    end
  end

end # << self
end # /Activites
end # / Cron
