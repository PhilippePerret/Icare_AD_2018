# encoding: UTF-8
class Signup
class << self

  # Fichier Marshal correspondant à l'étape +etape+
  def marshal_file etape
    folder_tmp_session + "#{etape}.msh"
  end
  # Dossier pour enregistrer les résultats de chaque étape, dans
  # un fichier marshal (donc .msh) qui porte le nom de l'étape
  # courante.
  def folder_tmp_session
    @folder_tmp_session ||= site.folder_tmp + "signup/#{app.session.session_id}"
  end

end #/<< self
end #/Signup
