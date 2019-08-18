# encoding: UTF-8
class Signup
class << self

  def params
    @params ||= param(:signup) || Hash.new
  end

  # Étape courante
  # --------------
  # Parmi 'identite', 'modules', 'documents', 'confirmation'
  def state ; @state ||= params[:state] || 'identite' end
  def state= val ; @state = val end

  # Return true si l'étape +etape+ a été traitée
  # Permet de lui mettre un lien ou de recharger les informations
  def state_done?(etape)
    marshal_file(etape).exist?
  end

  def bind ; binding() end

  # Dossier contenant les différentes vues de l'inscription
  def folder_views
    @folder_views ||= User.folder + 'lib/module/signup/view'
  end

end #/<< self
end #/Signup
