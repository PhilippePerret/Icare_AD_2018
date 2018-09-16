# encoding: UTF-8
class Cron
class Message
class << self

  # Pour récupérer le contenu du log, pour les tests
  attr_reader :logs

  # Pour consigner un message
  def log str, options = nil
    @logs ||= Array.new
    @logs << {content: str, options: (options || Hash.new)}
  end

  # Envoi du message à l'administrateur, mais seulement s'il y a des
  # choses à dire.
  def send_admin_report
    return if @logs == nil || @logs.count == 0
    send_mail_to_admin(
      subject:    "Un rapport de fin - #{Time.now}",
      message:    self.admin_report,
      formated:   true,
      no_header:  true
    )
  end

  # Écriture du rapport dans un fichier, toutes les heures
  def write_report
    return if @logs == nil || @logs.count == 0
    report_file.append "\n\n--- #{Time.now} ---\n#{admin_report}"
  rescue Exception => e
    debug e
  end

  # SuperFile dans lequel doit être enregistré le rapport
  def report_file
    @report_file ||= SuperFile.new([APP_FOLDER, 'CRON', 'report.html'])
  end

  # Construction du rapport administrateur
  def admin_report
    @admin_report ||= begin
      messages_log = @logs.collect{|h| h[:content].in_div(class: h[:options][:class])}.join
      <<-TXT
  <h2>Messages logs</h2>
  #{messages_log}
      TXT
    end
  end

end #/<< self
end #/Message
end #/Cron
