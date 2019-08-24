# encoding: UTF-8
class Signup

  DATA_STATES = {
    identite:     {hname: 'Informations personnelles', numero: 1},
    modules:      {hname: 'Choix des modules d’apprentissage', numero: 2},
    documents:    {hname: 'Documents de présentation', numero: 3},
    confirmation: {hname: 'Confirmation du dépôt', numero: 4}
  }

class << self

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

  def bind ; binding() end

  # Chargement de la vue (dans le dossier signup/view/)
  def view relpath
    (folder_pages+relpath).deserb(self)
  end

  def page_form_identite
    (current_data = get_identite) && param(user: current_data)
    Signup.view('1_form_identite.erb')
  end

  def page_form_modules
    param( modules_checked: (get_modules || Array.new) )
    Signup.view('2_form_modules.erb')
  end
  def page_form_documents
    Signup.view('3_form_documents.erb')
  end

  def page_confirmation
    Signup.view('4_page_confirmation.erb')
  end

  # Dossier contenant les différentes vues de l'inscription
  def folder_pages
    @folder_pages ||= site.folder_objet+'user/signup/lib/pages'
  end

end #/<< self
end #/ Signup
