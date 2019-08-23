# encoding: UTF-8
class Signup
class << self

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

end #/<< self
end #/ Signup
