# encoding: UTF-8
class SiteHtml
class Admin
class Console

  def run_script_console args
    args = args.split(' ')
    script = args.shift
    folder_scripts = './lib/app/console_scripts'
    case script
    when 'list'
      # Afficher la liste des scripts
      Dir["#{folder_scripts}/**/*.rb"].each do |pat|
        sub_log pat.sub!(/^#{Regexp::escape folder_scripts}\//o, '').in_div
      end
    else
      # On doit jouer le script
      script.end_with?('.rb') || ( script += '.rb' )
      path_script = File.join(folder_scripts, script)
      if File.exist? path_script
        require path_script # ça doit lancer le script
      else
        raise "Le script `#{path_script}` est introuvable."
      end
    end
    ""
  end

end #/Console
end #/Admin
end #/SiteHtml
