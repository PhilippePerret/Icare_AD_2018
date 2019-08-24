# encoding: UTF-8
class Signup
class << self

  def traite_operation
    case params[:operation]
    when 'save_identite'
      save_identite   && self.state = 'modules'
    when 'save_modules'
      save_modules    && self.state = 'documents'
    when 'save_documents'
      save_documents && begin
        self.state = 'confirmation'
        User.create_candidature
      end
    end
  end

end #/<< self
end #/Signup
