# encoding: UTF-8
class User

  attr_reader :errors

  # Pour ajouter une erreur
  def add_error mess_err
    @errors ||= Array::new
    @errors << mess_err
  end

end #/User
