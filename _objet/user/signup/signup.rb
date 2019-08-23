# encoding: UTF-8

require_folder(site.folder_objet+'user/signup/lib')
class Signup
class << self

  attr_accessor :new_user # on en aura besoin dans les vues

  def params
    @params ||= param(:signup) || Hash.new
  end

  # Retourne le code HTML de la page courante
  def current_page
    case state
    when NilClass, 'identite'
      page_form_identite
    when 'modules'
      page_form_modules
    when 'documents'
      page_form_documents
    when 'confirmation'
      page_confirmation
    end
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
  def folder_pages
    @folder_pages ||= site.folder_objet+'user/signup/lib/pages'
  end

end #/<< self
end #/Signup
