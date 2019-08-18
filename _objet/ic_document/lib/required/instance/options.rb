# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Bits d'options :
  #   0 / 8     Existence du fichier original / commentaires
  #   1 / 9     Niveau de partage du fichier original / commentaires (partage)
  #             0: non défini, 1: partagé, 2: non partagé
  #   2 / 10    Téléchargement du fichier original (admin) / commentaires (auteur)
  #             Donc original: par admin, comments: par auteur
  #   3 / 11    Uploadés sur le QDD (original/commentaires)
  #   4 / 12    Partage défini (doublon avec le 2e bit ?)
  #   5 / 13    Fin de cycle (1) ou non (0 - défaut)

  def options; @options ||= get(:options) || self.class.default_options end

  # acces(:original) ou acces => retourne la valeur de l'accès à l'original
  # acces(false). Peut être 0: non défini, 1: partagé, 2: non partagé ou
  # 3: pas de document.
  def acces type = true
    options[type == :original ? 1 : 9].to_i
  end


end #/IcDocument
end #/IcEtape
end #/IcModule
