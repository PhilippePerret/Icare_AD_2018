# encoding: UTF-8
=begin
  Utilisé pour ouvrir un fichier Markdown

  @usage

    href: "site/open_md_file?path=le/path/du/fichier.md"

  NOTE

    Il vaut mieux utiliser le fichier open_file avec l'href:

    "site/open_file?path=le/path[&app=application]"
    
=end
def osascript(script)
  command = "osascript -e \"#{script}\" 2>&1"
  debug "command: #{command}"
  res = `#{command}`
  debug "res: #{res.inspect}"
end

if File.exist? param(:path)
  osascript "tell application \\\"#{site.markdown_application}\\\" to open \\\"#{param(:path).gsub(/\//,':')}\\\""
  flash "Ouverture de #{param :path}"
else
  error "La page #{param :path} est introuvable. Impossible de l'ouvrir."
end

redirect_to :last_route
