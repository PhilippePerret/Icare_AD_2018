# encoding: UTF-8
class App

  # Requérir un module ou autre optionnel
  # +relpath+ Chemin relatif depuis le dossier :
  # ./lib/deep/deeper/optional
  def require_optional relpath
    p = site.folder_lib_optional + relpath
    if p.exist?
      p.require
    elsif false == relpath.end_with?('.rb')
      p = site.folder_lib_optional + "#{relpath}.rb"
      p.require if p.exist?
    end
  end

end
