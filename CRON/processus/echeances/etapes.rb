# encoding: UTF-8
class EcheanceEtape
class << self
  # = main =
  #
  # Traitement des échéances de paiement
  def traite
    # On prend les users actifs et on les traite
    drequest = {
      where: 'SUBSTRING(options,17,1) = "2" AND SUBSTRING(options,4,1) != "1"', # actifs
      colonnes: []
    }
    dbtable_users.select(drequest).each do |huser|
      User.new(huser[:id]).traite_echeances_etapes
    end
  end

end #/<< self
end #/EcheanceEtape
class User

  def traite_echeances_etapes
    # Si l'user a rendu son travail et qu'il est en attente de retour de
    # commentaires, il ne peut pas avoir d'échéance en retard
    icetape.status < 2  || return

    nombre_jours = (NOW - icetape.expected_end) / 1.day
    nombre_jours > 4 || return
    # L'échéance est dépassée de plus de quatre jours
    # ----------------------------------------------
    # On n'envoie un mail que tous les quatres jours de retard
    nombre_jours % 4 == 0 || return

    # On prend le niveau du dernier avertissement
    opts = icetape.options || ''
    level_warn = opts[0].to_i + 1
    level_warn < 6 || begin
      # Échéance non modifiée après trop d'avertissements
      # --------------------------------------------------
      # on avertit l'administration
      site.send_mail_to_admin(
        subject:  'Module à arrêter',
        formated:  true,
        message: <<-HTML
        <p>Phil</p>
        <p>Malgré 5 alertes, #{pseudo} n'a pas modifié son échéance ou envoyé ses documents de travail…</p>
        <p>Il faut forcer l'arrêt de son module d'apprentissage.</p>
        HTML
      )
      # seulement 5 niveaux d'avertissement. Après, normalement,
      # le module devrait être arrêté ou mis en pause.
      level_warn = 5
    end
    # On envoie le mail
    # -----------------
    # Les mails sont définis dans le dossier :
    # ./_objet/ic_etape/lib/mail
    send_mail(
      subject:    'Échéance de travail d’étape dépassée',
      formated:   true,
      message:    lire_mail_echeance_etape(level_warn)
    )
    # On modifie le niveau du dernier avertissement
    icetape.set(options: opts.set_bit(0, level_warn))
    log "  - Avertissement de niveau #{level_warn} envoyé à #{pseudo} pour un dépassement d'échéance de travail d'étape de #{nombre_jours} jours"
  rescue Exception => e
    backtrace = e.backtrace.join("\n")
    log "   # ERREUR au traitement des échéances de #{pseudo} (##{id}) : #{e.message}\n#{backtrace}"
  end
  #/traite_echeances

  def lire_mail_echeance_etape level_warn
    pmail = (IcModule::IcEtape.folder+"lib/mail/depassement_#{level_warn}.erb")
    pmail.deserb(self.bind)
  rescue Exception => e
    # Une erreur se produit ici avec jour_depassement et un expected_end
    # qui est inconnu.

    # On transforme la trace en string
    trace_erreur = e.backtrace.unshift(e.message).join("\n")
    # On définit les informations utilisateur
    user_info = '%{pseudo} (%{id})' % {self.pseudo, self.id}
    # On prendra le niveau d'alerte
    alerte_niveau = 'Niveau d’alerte : %s' % level_warn.to_s

    site.send_mail_to_admin(
      subject:  'Erreur dans `lire_mail_echeance_etape`',
      formated:  true,
      message: <<-HTML
      <pre>
        ERREUR AVEC : #{user_info}
        ERREUR :
        #{trace_erreur}
        POUR INFO :
        #{alerte_niveau}
      </pre>
      HTML
      )

  end

end
