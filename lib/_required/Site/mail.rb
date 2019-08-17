# encoding: UTF-8
class SiteHtml

  # @usage:   site.send_mail(data_mail)
  # Cf. module/Site/mail.rb pour le détail
  def send_mail data_mail
    site.require_module 'mail'
    resultat = exec_send_mail( data_mail )
    if resultat === true
      # Tout s'est bien passé
    else
      debug resultat
    end
    return resultat
  end

  # Envoi d'un mail à l'administration par
  # l'user courant
  # +data_mail+ a juste à définir :
  #   :message
  #   :subject
  #
  # La méthode peut être utilisée par le cron job par exemple
  # et, dans ce cas, l'user ne doit pas être défini, il faut
  # donc mettre le mail du site.
  #
  # On empêche les erreurs récurrentes en mettant une limite aux
  # passages par cette méthode.
  #
  # Noter qu'on demande de ne pas mettre l'header customisé dans
  # ces mails, pour faciliter la tâche.
  #
  def send_mail_to_admin data_mail
    @nombre_mails_to_admin ||= 0
    @nombre_mails_to_admin += 1
    @nombre_mails_to_admin < 4 || return
    expediteur =
      if user && user.instance_of?(User) && user.mail
        user.mail
      else
        site.mail
      end
    send_mail data_mail.merge(from: expediteur, to: site.mail, no_header: true)
  end

end
