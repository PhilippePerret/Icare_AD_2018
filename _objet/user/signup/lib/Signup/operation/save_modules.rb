# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_modules
    if data_modules_valides?
      marshal_file('modules').write Marshal.dump(modules_choisis)
      return true
    else
      error "Il faut optionner au moins un module d’apprentissage !"
      return false
    end
  end

  # Récupère les données de modules (liste des IDs) si le fichier
  # existe ou retourne nil
  def get_modules
    marshal_file('modules').exist? || (return nil)
    Marshal.load(marshal_file('modules').read)
  end

  def data_modules_valides?
    param(:signup_modules) && modules_choisis.count > 0
  end

  # Retourne la liste Array des identifiants des modules choisis
  def modules_choisis
    param(:signup_modules).collect do |mid, ison|
      mid.to_s.to_i
    end
  end


end #/<< self
end #/ Signup
