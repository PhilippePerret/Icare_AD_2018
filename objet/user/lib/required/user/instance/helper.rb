# encoding: UTF-8
class User

  # Cette méthode surclasse la méthode d'origine
  def htype
    hu = "utilisa#{f_trice}"
    ic = "icarien#{f_ne}"
    case true
    when admin?         then "administra#{f_trice}"
    when en_attente?    then "#{ic} en attente"
    when actif?         then "#{ic} acti#{f_ve}"
    when inactif?       then "#{ic} inacti#{f_ve}"
    when en_pause?      then "#{ic} en pause"
    when guest?         then "simple utilisateur"
    end
  end

  def hstatut
    case true
    when admin?       then 'administrateur'
    when actif?       then 'actif'
    when inactif?     then 'inactif'
    when en_pause?    then 'en pause'
    when en_attente?  then 'en attente'
    else                   'indéfini'
    end
  end

  # Retourne un texte de type "d'utilisatrice abonnée" ou
  # "de simple utilisateur"
  def de_htype
    case true
    when guest? then  "de #{htype}"
    else              "d’#{htype}"
    end
  end

end
