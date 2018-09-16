# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Détruit le fichier CRON2/cron_error.log
  def delete_error_log_cron
    res = ssh_delete_error_log_cron
    human_res =
      if res.nil?
        'Fichier ONLINE cron_error.log détruit (il a été copié en local)'
      else
        "# ERREUR Le fichier online cron_error.log n’a pas pu être détruit : #{res}"
      end
    return human_res
  end
  # Méthode qui procède à la destruction du log cron d'erreur
  # Mais avant de le détruire, on le recopie en local
  def ssh_delete_error_log_cron
    # On récupère le fichier
    path = File.expand_path("./CRON2/cron_error.log")
    File.unlink path if File.exist? path
    `scp #{serveur_ssh}:./data/CRON2/cron_error.log '#{path}'`
    cmd = "ssh #{serveur_ssh} 'rm ./data/CRON2/cron_error.log 2>&1'"
    return `#{cmd}`
  end

  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro.new.serveur_ssh
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
