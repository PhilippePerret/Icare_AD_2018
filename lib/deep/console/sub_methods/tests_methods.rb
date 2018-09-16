# encoding: UTF-8
class SiteHtml
class Admin
class Console

  RSPEC_COMMAND = site.rspec_command #.sub(/\/bin\//, '/wrappers/')

  # Les arguments transmis au méthodes principales
  attr_reader :args

  def run_test_rspec args
    thisf = File.expand_path('.')
    sub_log `cd #{thisf};#{RSPEC_COMMAND} #{args} 2>&1`
  end

  def run_a_test args = nil
    @args = args
    site.require_module 'test'
    if args == nil || args == 'run'
      # Il faut jouer le fichier ./test/run.rb
      inst = SiteHtml::TestSuite::new(nil)
      require './test/run'
    else
      # Utilisation "normale" des tests
      inst = SiteHtml::TestSuite::new( parse_arguments )
    end
    inst.run
  end

  # Répond à la commande `test show db`
  # +options+ peut être un mot ajouté à la fin de la commande
  # ci-dessus, par exemple pour préciser qu'il faut voir une table
  # en particulier ou "all" pour les voir toutes.
  # TODO: C'est à implémenter, pour le moment, +options+ ne sert à
  # rien.
  def show_db_after_tests options = nil
    site.require_module 'test'
    SiteHtml::TestSuite.display_db_after_test( options )
    return ""
  end

  def parse_arguments
    # On explode les arguments. Noter que si la
    # commande `test` est jouée seule, ces arguments sont vides
    # et il faut jouer le dossier "offline" entier
    where = :offline # Par défaut
    opts  = Hash.new
    dossier_test, dossier_rspec = if args != ""

      dargs = args.split(' ')
      if dargs.last == "online" || dargs.last == "offline"
        where = (dargs.pop == "online") ? :online : :offline
      end

      # On recherche les options dans les commandes transmises
      dargs = dargs.collect do |arg|
        next arg unless arg.start_with?('-')
        if arg.start_with?('--')
          prop, value = arg[2..-1].strip.split('=')
          value = case value
          when 't' then true
          when 'f' then false
          else value
          end
          opts.merge!(prop.to_sym => value)
        else
          table_one_letter = {
            'v' => :verbose,
            'q' => :quiet,
            'd' => :documented
          }
          arg[1..-1].strip.split('').each do |lettre_option|
            opt = table_one_letter[lettre_option]
            unless opt.nil?
              opts.merge!( opt => true )
            else
              opts.merge!( lettre_option => true )
            end
          end
        end
        nil
      end.compact

      # Quel test ? Soit un raccourci, soit un dossier
      # existant dans les tests
      list = ['.', 'spec', "#{where}", dargs.first].compact
      [dargs.first, File.join(*list)]
    else
      # Dans le cas où la commande `test` a été jouée toute
      # seule
      [nil, File.join('.','spec','offline')]
    end
    # Hash d'options retourné
    {
      dossier_rspec:  dossier_rspec,
      dossier_test:   dossier_test,
      where:          where,
      online:         (where == :online),
      offline:        (where == :offline),
      options:        opts
    }
  end
  def run_a_rspec_test args
    unless RSPEC_COMMAND!=nil && ( File.exist? RSPEC_COMMAND )
      raise "Pour pouvoir jourer les tests, vous devez spécifier l'emplacement du binaire `rspec` dans le fichier de configuration `./site/config.rb` avec `site.rspec_command = ...`."
    end
    @args = args
    opts = parse_arguments
    dossier_test = opts.delete(:dossier_test)

    raise "Le dossier de test `#{dossier_test}` est introuvable" if !File.exist?(dossier_test)

    app_folder = File.expand_path('.')
    res = site.osascript <<-END
     tell application "Terminal"
       activate
       activate
       do script "clear" in front window
       do script "cd #{app_folder}" in front window
       do script "rspec #{dossier_test}"  in front window
     end tell
    END
    if res =~ /^tab 1 of window id/
      # => OK
      sub_log "Test exécuté avec succès."
    else
      sub_log "Une erreur est survenue : #{res}"
      sub_log "(penser à ouvrir une fenêtre dans le Terminal)"
    end

  rescue Exception => e
    debug e
    error e.message
  ensure
    return ""
  end

end #/Console
end #/Admin
end #/SiteHtml
