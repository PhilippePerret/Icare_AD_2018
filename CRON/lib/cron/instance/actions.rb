# encoding: UTF-8
class Cron

  # Exécution de tous les processus CRON à lancer, en fonction
  # de l'heure.
  #
  # Rappel : le cron-job travaille toutes les heures.
  # On peut mettre :each_time en valeur de fréquence (2e argument) lorsqu'on
  # augmente la fréquence de lancement du cron (par exemple toutes les 5
  # minutes) lorsque l'on fait des essais.
  #
  def exec

    run_processus 'mail_activites', :once_an_hour

    run_processus 'nettoyage_site', :once_a_day

    run_processus 'echeances',      :once_a_day

  end

  # Méthode appelée en fin de processus de cron, toutes les
  # heures. Elle sert principalement à envoyer le rapport de cron
  # à l'administrateur si c'est nécessaire.
  def stop
    # On envoie le rapport à l'administrateur
    # Cron::Message.send_admin_report
    # On écrit le rapport dans un fichier
    Cron::Message.write_report
  end

  # = MAIN =
  #
  # Méthode principale qui joue le processus.
  #
  # La date de dernière exécution est enregistrée dans la table
  #
  def run_processus proc_name, frequence = :once_a_day
    REF_LOG_SUIVI.write " -> cron.run_processus('#{proc_name}', #{frequence.inspect})…\n"
    Processus.new(proc_name).run_if_needed(frequence)
  rescue Exception => e
    REF_LOG_SUIVI.write " ERROR : #{e.message}"
    bt = e.backtrace.join("\n")
    log "### ERREUR EN EXECUTANT LE PROCESSUS #{proc_name} : #{e.message}\n#{bt}"
  else
    REF_LOG_SUIVI.write " <- /cron.run_processus('#{proc_name}', #{frequence.inspect})…\n"
  end

  def folder_processus
    @folder_processus ||= SuperFile.new([FOLDER_CRON, 'processus'])
  end

end #/Cron
