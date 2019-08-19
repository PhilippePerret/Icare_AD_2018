#!/usr/bin/env ruby
# encoding: UTF-8

=begin

  Les actions du cron-job sont définies dans le fichier :

    ./CRON/lib/cron/instance/actions.rb

=end

# Dossier CRON dans la racine du site
FOLDER_CRON = File.dirname(File.expand_path(__FILE__))
FOLDER_LIB  = File.join(FOLDER_CRON, 'lib')

# Path au fichier qui doit contenir le suivi du programme
LOG_SUIVI = File.join(FOLDER_CRON, 'suivi_processus.log')
# L'ouverture au fichier de suivi, en constante pour ne pas avoir de problème
# @usage :
#   Utiliser `REF_LOG_SUIVI.write "<quelque chose>\n"` pour écrire un message
#   de suivi depuis n'importe où, sans erreur.
REF_LOG_SUIVI = File.open(LOG_SUIVI, 'a')

def log_fatal_error
  @log_fatal_error ||= begin
    rf = File.join(FOLDER_CRON, 'cron_fatal_error.log')
    File.open(rf, 'a'){|f| f.write "\n\n\n=== CRON JOB - ERREUR FATALE #{Time.now} ===\n"}
    rf
  end
end

begin

  REF_LOG_SUIVI.write "\n\n=== CRON JOB DU #{Time.now} ===\n"

  REF_LOG_SUIVI.write "* Chargement du fichier CRON/lib/required… "
  require File.join(FOLDER_LIB,'required')
  REF_LOG_SUIVI.write "OK\n"

  # On se place à la racine du site
  Dir.chdir(APP_FOLDER) do
    ONLY_REQUIRE = true

    REF_LOG_SUIVI.write "* Chargement du fichier _lib/required du site… "
    require './_lib/required'
    REF_LOG_SUIVI.write "OK\n"
    # ==========================

            REF_LOG_SUIVI.write "* --> cron.exec…\n"
            cron.exec
            REF_LOG_SUIVI.write "<-- /cron.exec\n"
            REF_LOG_SUIVI.write "* --> cron.stop…\n"
            cron.stop
            REF_LOG_SUIVI.write "<-- /cron.stop (#{Time.now})\n"
    # ==========================
  end

rescue Exception => e
  backtrace = e.backtrace.join("\n")
  fatal_error = "ERREUR FATALE #{Time.now.strftime('%d %m %Y - %H:%M')}\n\n#{e.message}\n#{backtrace}"
  File.open(log_fatal_error, 'a'){|f| f.write fatal_error}
end
