# encoding: UTF-8
=begin

Pour ouvrir n'importe quel fichier dans n'importe quelle application,
mais seulement si l'on est un administrateur.

@usage

    site/open_file?path=le/path/du/fichier.ext&app=<l'application>

@note

    * Si aucun application n'est précisé, c'est TextMate (plutôt que
    Atom) qui est choisi, quel que soit les réglages de config.rb

    * `path` peut être remplacé par `file`

=end
raise_unless_admin

path = param(:path) || param(:file) || (raise "Aucun fichier n'est défini !" )
File.exist?(path) || path = File.expand_path(path)
File.exist?(path) || raise("Le fichier `#{path}` est introuvable !")
debug "Path à ouvrir: #{path}"
if File.exist? path
  # osascript "tell application \\\"#{param(:app)}\\\" to open \\\"#{param(:path).gsub(/\//,':')}\\\""
  extname = File.extname(path)
  case extname
  when '.pdf'
    # Ça ne fonctionne pas encore
    raise 'Impossible, encore, d’ouvrir un PDF de cette façon'
    app = "Aperçu"
    # cmd = "open \"#{path}\""
    cmd = "/Applications/Preview.app/Contents/MacOs/Preview \"#{path}\""
  else
    app = param(:app) || "TextMate"
    cmd = "open -a #{app} \"#{path}\""
  end
  debug "Command: #{cmd}"
  # On exécute la commande
  debug `#{cmd} 2>&1`
  # flash "Ouverture de #{path} dans #{app}"
else
  error "La page #{path} est introuvable. Impossible de l'ouvrir."
end
