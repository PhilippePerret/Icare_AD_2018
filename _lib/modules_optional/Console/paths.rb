# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Dossier contenant les méthodes propres à l'application
  # courante.
  # Rappel : On peut les charger par `console.require` ou
  # `console.load`
  def folder_app
    @folder_app ||= site.folder_lib + 'console/app'
  end

  # Dossier console
  def folder_console
    @folder_console ||= site.folder_lib + '/console'
  end

end #/Console
end #/Admin
end #/SiteHtml
