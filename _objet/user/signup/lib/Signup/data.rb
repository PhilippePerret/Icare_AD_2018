# encoding: UTF-8

class Signup

  DATA_STATES = {
    identite:     {hname: 'Informations personnelles', numero: 1},
    modules:      {hname: 'Modules d’apprentissage optionnés', numero: 2},
    documents:    {hname: 'Documents de candidature', numero: 3},
    confirmation: {hname: 'Confirmation du dépôt', numero: 4}
  }

class << self

  attr_accessor :new_user # on en aura besoin dans les vues

  def titre
    'Poser sa candidature'
  end
  def data_onglets;end

  def params
    @params ||= param(:signup) || Hash.new
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

  # Étape courante
  # --------------
  # Parmi 'identite', 'modules', 'documents', 'confirmation'
  def data_state
    DATA_STATES[state.to_sym]
  end
  def state ; @state ||= params[:state] || 'identite' end
  def state= val ; @state = val end

  # Return true si l'étape +etape+ a été traitée
  # Permet de lui mettre un lien ou de recharger les informations
  def state_done?(etape)
    marshal_file(etape).exist?
  end

end #/<< self
end #/Signup
