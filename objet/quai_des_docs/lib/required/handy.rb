# encoding: UTF-8

# Retourne soit l'année courante
def annee_courante
  @annee_courante ||= begin
    (param(:an) || annee_of_time).to_i
  end
end
# Le trimestre courant de 1 à 4
# Soit le trimestre d'aujourd'hui, soit le trimestre défini par
# le paramètre `tri`
def trimestre_courant
  @trimestre_courant ||= begin
    (param(:tri) || trimestre_of_time).to_i
  end
end

# Reçoit un temps (soit {Time} soit un nombre de secondes) et retourne
# l'année correspondante
def annee_of_time time = nil
  time != nil || time = Time.now
  time.instance_of?(Fixnum) && time = Time.at(time)
  time.year
end
# Reçoit un temps (soit {Time}, soit un nombre de secondes) et retourne
# l'index 1-start du trimestre correspondant
def trimestre_of_time time = nil
  time != nil || time = Time.now
  time.instance_of?(Fixnum) && time = Time.at(time)
  1 + ((time.month - 1)/ 3)
end

# Inverse de la précédente, reçoit une année et un trimestre et
# retourne le {Time} correspondant (début du trimestre)
def start_of_trimestre annee = nil, trimestre = nil
  annee     ||= annee_courante
  trimestre ||= trimestre_courant
  Time.new(annee, ((trimestre - 1) * 3) + 1, 1, 0, 0, 0)
end
# Retourne le temps de la fin du trimestre, en secondes
def end_of_trimestre annee = nil, trimestre = nil
  annee     ||= 0 + annee_courante
  trimestre ||= 0 + trimestre_courant
  if trimestre == 4
    Time.new(annee + 1, 1, 1, 0, 0, 0)
  else
    Time.new(annee, trimestre * 3 + 1, 1, 0, 0, 0)
  end
end
