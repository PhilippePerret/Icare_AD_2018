# encoding: UTF-8

class Signup
class << self

  attr_accessor :new_user # on en aura besoin dans les vues

  def titre
    'Poser sa candidature'
  end
  def data_onglets;end


  def params
    @params ||= param(:signup) || Hash.new
  end

  # Étape courante
  # --------------
  # Parmi 'identite', 'modules', 'documents', 'confirmation'
  def data_state
    @data_state ||= DATA_STATES[state.to_sym]
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
