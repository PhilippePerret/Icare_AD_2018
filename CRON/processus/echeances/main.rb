# encoding: UTF-8
class Cron

  def _echeances
    begin
      EcheancePaiement.traite
    rescue Exception => e
      log "# ERREUR en traitant les dépassements d'échéance de paiement : #{e.message}"
      log e.backtrace.join("\n")
    end
    begin
      EcheanceEtape.traite
    rescue Exception => e
      log "# ERREUR en traitant les dépassements d'échéance d'étapes : #{e.message}"
      log e.backtrace.join("\n")
    end
  end

end#/Cron
