# encoding: UTF-8
class IcModule
class IcEtape

  # STATUT DE L'ÉTAPE (propriété status - avec un "s")
  # -----------------
  # 0 Normalement, n'est jamais affecté
  # 1 L'étape est démarrée, l'icarien travaille.
  # 2 L'icarien a remis ses documents, mais ils n'ont pas encore été reçus
  # 3 Réception (download) des documents par Phil
  # 4 Dépôt (upload) des commentaires par Phil
  # 5 Réception (download) des commentaires par l'icarien
  # 6 Dépôt (upload) des documents sur le QDD
  # 7 Définition du partage par l'icarien

  def stated? ; status > 0 end
  def ended?  ; status > 6 end

  # Renvoie true si l'étape a été considérée comme une étape réelle
  def real?
    bit_etape_reelle == 1
  end

end #/IcEtape
end #/IcModule
