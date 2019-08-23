# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_identite
    data_valides? || (return false)
    # On enregistre les données dans le fichier marshal
    marshal_file('identite').write Marshal.dump(data2save)
  end

  # Méthode qui récupère les données de l'identité dans le
  # fichier Marshal et les renvoie.
  # Cette méthode appelée chaque fois que la page de l'identité
  # est appelée.
  # Return NIL si le fichier n'existe pas encore
  def get_identite
    marshal_file('identite').exist? || (return nil)
    Marshal.load(marshal_file('identite').read)
  end

  def data2save
    now = Time.now.to_i
    {
      pseudo:       @pseudo,
      patronyme:    @patronyme,
      sexe:         @sexe,
      naissance:    @naissance,
      mail:         @mail,
      mail_confirmation: @mail,
      password:     @password,
      password_confirmation: @password,
      telephone:    @phone,
      adresse:      @adresse,
      session_id:   app.session.session_id,
      options:      '0'*10,
      created_at:   now,
      updated_at:   now
    }
  end

end #/<< self
end #/ Signup
