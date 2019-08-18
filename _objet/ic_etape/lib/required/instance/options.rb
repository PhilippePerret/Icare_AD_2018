# encoding: UTF-8
class IcModule
class IcEtape

  # BIT 0 (1er)
  # Bit d'avertissement d'échéance d'étape dépassée
  # C'est un nombre de 0 à 9 pour savoir quel mail a été envoyé
  # suite à une échéance de travail dépassé
  # 0: aucun mail envoyé, 1: simple avertissement à 9: menace de rejet
  #
  # NOTES
  #   * les mails sont gérés par le CRON
  #   * les mails sont définis dans le dossier ???
  #   * le bit est remis à 0 à chaque changement d'échéance
  #
  def bit_overrun_echeance
    options[0].to_i
  end

  # BIT 1 (2e)
  # Si 1, l'étape est considérée comme une étape "réelle", c'est-à-dire
  # une étape décomptée dans les 8 étapes que doit suivre l'icarien.
  def bit_etape_reelle
    options[1].to_i
  end
  
end #/IcEtape
end #/IcModule
