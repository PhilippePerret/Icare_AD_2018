# encoding: UTF-8
class Signup
class << self

  def page_form_identite
    (current_data = get_identite) && param(user: current_data)
    Signup.view('form_identite.erb')
  end

  def page_form_modules
    param( modules_checked: (get_modules || Array.new) )
    Signup.view('form_modules.erb')
  end
  def page_form_documents
    Signup.view('form_documents.erb')
  end

  def page_confirmation
    Signup.view('page_confirmation.erb')
  end

end #/<< self
end #/ Signup
