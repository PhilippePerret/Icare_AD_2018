# encoding: UTF-8
class EcheancePaiement
class << self

  # = main =
  #
  # Traitement des dépassements d'échéances de paiement
  # On ne traite que les icariens actifs
  def traite
    drequest = {
      where: 'SUBSTRING(options,17,1) = "2" AND SUBSTRING(options,4,1) != "1"', # actifs
      colonnes: []
    }
    dbtable_users.select(drequest).each do |huser|
      User.new(huser[:id]).traite_echeance_paiement
    end
  end
  #/traite

end #/<< self
end #/EcheancePaiement

class User

  def traite_echeance_paiement
    # On ne prend que les icariens qui ont un paiement à
    # effectuer
    icmodule.next_paiement != nil || return
    nombre_jours = (NOW - icmodule.next_paiement) / 1.day
    # Si l'icarien est à plus de 4 jours de retard d'échéance,
    # on le traite.
    nombre_jours > 4 || return
    # On envoie un mail à l'icarien tous les 5 jours
    nombre_jours % 5 || return
    level_warn = 1 + bit_echeance_paiement
    # Il y a 5 niveau d'alerte. Au bout du 5e niveau, on avertit
    # l'administration
    level_warn < 5 || begin
      site.send_mail_to_admin(
        subject:  'Paiement non effecuté',
        formated:  true,
        message: <<-HTML
<p>Phil,</p>
<p>L'icarien #{pseudo} (##{id}) a reçu 5 alertes concernant son dépassement d'échéance de paiement, sans réponse.</p>
<p>Il faut à présent procéder à sa radiation de l'atelier…</p>
        HTML
      )
      level_warn = 5
    end

    # On envoie le mail
    # -----------------
    # Les mails sont définis dans le dossier :
    # ./objet/ic_etape/lib/mail
    send_mail(
      subject:    'Dépassement d\'échéance de paiement',
      formated:   true,
      message:    lire_mail_echeance_paiement(level_warn)
    )

    # On modifie le niveau du dernier avertissement
    set(options: options.set_bit(25, level_warn))

    log "  - Avertissement de niveau #{level_warn} envoyé à #{pseudo} pour un DÉPASSEMENT D'ÉCHÉANCE DE PAIMENT de #{nombre_jours} jours."
  rescue Exception => e
    backtrace = e.backtrace.join("\n")
    log "   # ERREUR au traitement de l'échéance de paiement de #{pseudo} (##{id}) : #{e.message}\n#{backtrace}"
  end
  # /traite_echeance_paiement

  def lire_mail_echeance_paiement level_warn
    pmail = (site.folder_objet+"ic_paiement/lib/mail/depassement_paiement_#{level_warn}.erb")
    pmail.deserb(bind)
  end

end
