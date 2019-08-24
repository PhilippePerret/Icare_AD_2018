# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_identite
    if data_valides?
      # On enregistre les données dans le fichier marshal
      marshal_file('identite').write Marshal.dump(data2save)
      return true
    end
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
