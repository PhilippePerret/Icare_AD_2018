# encoding: UTF-8

# Instance de cron courante
def cron
  @cron ||= Cron.new
end


APP_FOLDER = File.dirname(FOLDER_CRON)

# On charge toutes les librairies
Dir["#{FOLDER_LIB}/**/*.rb"].each{|m| require m}
