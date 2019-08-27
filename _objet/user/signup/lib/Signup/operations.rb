# encoding: UTF-8
class Signup
class << self

  def traite_operation
    case params[:operation]
    when 'save_identite'
      save_identite && self.state = 'modules'
    when 'save_modules'
      self.state = save_modules ? 'documents' : 'modules'
    when 'save_documents'
      if save_documents
        debug "--- L'état est mis à 'confirmation'"
        self.state = 'confirmation'
        User.create_candidature
      else
        self.state = 'documents'
      end
    end
  end

end #/<< self
end #/Signup
