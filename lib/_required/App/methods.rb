# encoding: UTF-8
class App

  # Requérir un module ou autre optionnel
  # +relpath+ Chemin relatif depuis le dossier :
  # ./lib/modules_optional
  # TODO Il faudrait maintenant supprimer la méthode site.require_module pour
  # n'utiliser que celle-ci qui est plus logique. site.require_module n'est pas
  # logique pour 'site' est censé concerner la version front-stack de l'atelier
  def require_optional relpath
    p = site.folder_optional_modules + relpath
    if p.exist?
      p.require
    elsif false == relpath.end_with?('.rb')
      p = site.folder_optional_modules + "#{relpath}.rb"
      p.require if p.exist?
    end
  end

end
