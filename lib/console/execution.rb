# encoding: UTF-8
raise_unless_admin
site.require_module('Console')
class SiteHtml
class Admin
class Console

  # = Sauf en mode "pur ruby" =
  # Permet de créer une méthode d'instance qui va retourner
  # la valeur d'une variable définie au cours du code.
  # Par exemple, si on a :
  #   > ma_variable = get :id of {pseudo: "Phil"} in :icariens
  #   > debug "ma_variable vaut #{ma_variable}"
  # puisque la seconde ligne va être interprétée en ruby (le premier mot
  # n'est pas connu par le DSL qu'on utilise ici), il faut créer une
  # méthode `ma_variable` qui va retourner la valeur définie dans la
  # première ligne.
  def self.create_method_variable var_name, var_return
    define_method var_name do
      var_return
    end
  end


  def execute_code

    all_results = Array::new

    # Il faut charger les exécutions de commandes propres
    # à l'application.
    console.require 'execution_commandes.rb'
    console.require 'common'

    lines.each do |line|

      next if line.strip.start_with?('#')

      # On ajoute toujours la ligne au code qui sera ré-affiché dans
      # la console
      add_code line

      split_line = line.split(' ')
      second_word = split_line[1]

      if second_word == "="
        # => La ligne est une ligne d'affectation, il faut mettre
        # le résultat du membre de droite dans la variable membre
        # de gauche.
        variable_name = split_line[0]
        # result_line[:variable_name] = variable_name
        line = split_line[2..-1].join(' ')
      else
        variable_name = nil
      end

      resultat_eval = eval_line(line)

      if variable_name.nil?
        add_code("# => #{resultat_eval}") unless resultat_eval == ""
      else
        # Affectation à une variable
        self.class::create_method_variable variable_name, resultat_eval
        add_code( "# => #{variable_name} = #{resultat_eval.inspect}"  )
      end

      all_results << resultat_eval
    end

    return all_results.join("\n") # inscription dans console
  end

  # ---------------------------------------------------------------------
  #   Méthode d'analyse de chaque ligne
  # ---------------------------------------------------------------------
  def eval_line line
    # On marque la ligne pour pouvoir savoir ce qui a produit
    # le résultat
    log line, :code

    #
    # DÈS QU'UNE LIGNE EST AJOUTÉE, IL FAUT RENSEIGNER
    # LE FICHIER help.rb DE CONSOLE
    #
    res = false

    res ||= ( execute_as_regular_sentence line )

    # On exécute la ligne telle quelle
    res ||= ( execute_as_is line )

    # On exécute la ligne de type premier mot commande
    res ||= ( execute_as_first_word_command line )

    # On exécute la ligne de type dernier mot variable
    res ||= ( execute_as_last_is_variable line )

    # ON exécute la ligne de type get <foo> of <something> <id>
    res ||= ( execute_as_get_of_line line )

    # En dernier recours, on exécute la ligne comme du code
    # ruby
    res ||= execute_as_ruby( line )

    # On doit retourner le résultat tel quel car il peut
    # être affecté à une variable.
    return res

  rescue Exception => e
    error e.message
    debug "--- ERREUR : #{e.message}"
    debug e.backtrace.join("\n")
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'analyse de la phrase
  # ---------------------------------------------------------------------

  # Analyse de la ligne telle quelle
  def execute_as_is line
    case line.downcase

    # Aide générale
    when 'help', 'aide'
      sub_log help
      "" # Pour ne rien renvoyer
      # TESTS
    when 'run test'
      run_a_test
    when 'sync'
      redirect_to 'admin/sync'
      ""
      # --- TACHES ---

    when /^liste? ta(che|sk)s$/
      Taches.show_liste_taches
    when /^(liste? )?mes taches$/
      Taches.show_liste_taches( admin: user.id.to_s)
    when /^liste? ta(che|sk)s (.+)$/
      Taches.show_liste_taches( admin: line.split(' ').last )
    when /^synchro(nize|nise)? (taches|tasks)$/
      redirect_to 'admin/sync'
      ""
    when /^liste? (all|toutes) ta(che|sk)s$/
      Taches.show_liste_taches all: true

      # --- CRON ---
    when 'delete log error cron'
      require_submethods 'cron'
      return delete_error_log_cron

      # --- BASES DE DONNÉES ---

    when /^mysql online$/
      require_submethods 'mysql'
      return code_connexion_mysql_online
    when /^mysql offline$/
      require_submethods 'mysql'
      return code_connexion_mysql_offline
    when /^backup table ([^\.]+)\.(.+?)$/
      db, tbl = line.scan(/^backup table ([^\.]+)\.(.+?)$/).first
      backup_data_from_all "#{db}.db", tbl
      return ""
    when /^retrieve data(?: from)? table ([^\.]+)\.(.+?)$/
      db, tbl = line.scan(/^retrieve data(?: from)? table ([^\.]+)\.(.+?)$/).first
      retrieve_data_from_all( "#{db}.db", tbl )
      return ""

      # --- IMAGES ---

    when /^balise image/
      Images::balise_image line.sub(/^balise image/,'').strip
    # ---------------------------------------------------------------------
    # Toutes les aides directes
    when 'aide analyse'
      (site.folder_optional_modules+'console/console_aides/analyse.rb').require
      ::Console::Aide.analyse
    when /^aide (rédaction|redaction|markdown|kramdown)$/
      aide_redaction_markdown
      ""

      # --- FILES ---
    when /^kramdown ([^ ]+) (pdf|html|htm)$/
      tout, path, oformat = line.match(/^kramdown ([^ ]+) (pdf|html|htm)$/).to_a
      visualise_document_kramdown path, oformat
      ""
      # ---------------------------------------------------------------------
    when /^check (site|synchro)$/     then check_synchro
    when /^(read|show|afficher|affiche) debug$/ then read_debug
    when /^(destroy|kill) debug$/     then destroy_debug
    when /^vider? table paiements?$/  then vide_table_paiements
    when /(remove|détruire|kill) table paiements?$/
      remove_table_paiements
    when /^liste? gels?$/               then affiche_liste_des_gels
    else
      # Méthodes propres à l'application
      app_execute_as_is line
    end
  end

  def execute_as_first_word_command line
    words = line.split(' ')
    first_word = words.shift
    reste_line = words.join(' ').strip
    case first_word

      # --- Jouer un test rspec ----
    when 'rspec'
      run_test_rspec reste_line
      return ""
      # --- Jouer des scripts console ---
    when 'run'
      run_script_console reste_line

      # --- UPDATES (HISTORIQUE ACTUALISATIONS) ---

    when /^updates?/
      return (exec_updates reste_line)

      # --- TWITTER ---

    when /^(twitter|twitte|twit|tweet)$/
      return ( envoyer_tweet reste_line )

    when /^test$/

      # --- TESTS ---
      case line
      when /^test show db/
        return (show_db_after_tests line.sub(/^test show db/,'').strip)
      when /^test (liens|links|pages)/
        require_submethods 'links_analyzer'
        return test_all_pages line.sub(/^test (liens|links|pages)/,'').strip
      else
        return ( run_a_test reste_line )
      end

    when /^rspec$/

      # --- RSPEC ---

      return ( run_a_rspec_test reste_line)
    end
  end
  # On exécute la ligne (si on peut) comme une ligne composée
  # de `get <something> of <something else> <id something else>`
  # Par exemple, c'est ce qui est utilisé pour ÉCRIRE UN FILM/ROMAN EN UN AN
  # pour retrouver un work d'une page de cours, un p-day d'un
  # questionnaire, etc.
  def execute_as_get_of_line line
    marqueur = /([a-zA-Z0-9_\.\-]+)/
    found = line.match(/^get #{marqueur} of #{marqueur} ([0-9]+)$/)
    return nil if found.nil?
    get_of_exec(* found.to_a[1..3])
  end

  # On analyse la ligne comme une expression régulière connue
  def execute_as_regular_sentence line
    if (found = line.match(/^(creer|create|new|nouvelle) (tache|task) (.*?)$/).to_a).count > 0
      Taches.create_tache found[3].freeze
    elsif (found = line.match(/^(update|actualise)r? (tache|task) ([0-9]+) (.*?)$/).to_a).count > 0
      Taches.update_tache found[3].to_i, found[4].freeze
    elsif (found = line.match(/^(?:show|goto|go to|aller) (.*)$/).to_a).count > 0
      ( goto_section found[1].strip )
    elsif line.strip =~ /^([a-z_]+)\/([0-9]+)\/([a-z_]+)$/
      ( goto_section line.strip )
    else
      app_execute_as_regular_sentence line
    end
  end

  # On exécute la ligne comme si son dernier terme était
  # une variable
  def execute_as_last_is_variable line
    words = line.split(' ').reject { |m| m.strip == "" }
    last_word = words.pop
    sentence  = words.join(' ')
    # debug "sentence : '#{sentence}'"
    # debug "last word : '#{last_word}'"

    # On corrige last_word qui peut commencer par des
    # guillemets simples ou doubles
    if last_word.match( /^['"](.*?)['"]$/ )
      last_word = last_word[1..-2].strip
    end

    case sentence
    when 'help', 'aide'
      ( affiche_aide_for last_word )
    when 'finir tache', 'finir task', 'end task'
      ( Taches.marquer_tache_finie last_word )
    when /^(detruire|destroy|kill) (tache|task)/
      ( Taches.detruire_tache last_word)
    when 'kramdown'
      ( visualise_document_kramdown last_word )
    when /^(afficher|affiche|show|montre) table/
      ( affiche_table_of_database last_word )
    when 'vide table'
      ( vide_table_of_database last_word )
    when /^(kill|detruire|destroy) table/
      ( destroy_table_of_database last_word )
    when 'gel'
      ( gel last_word )
    when 'degel'
      ( degel last_word )
    else
      app_execute_as_last_is_variable sentence, last_word
    end
  end

  # Dans le cas où la ligne n'a pas pu être interprétée avant,
  # on essaie de l'exécuter telle quelle
  def execute_as_ruby line
    begin
      res = eval(line)
      "#{res.inspect}"
      # log "---> #{res.inspect}"
    rescue Exception => e
      error "Line injouable : `#{line}`"
      debug e
      "### LIGNE INCOMPRÉHENSIBLE ### #{e.message}"
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes utilisables
  # ---------------------------------------------------------------------
  def vide_table_paiements

    if OFFLINE
      User::table_paiements.delete
      if User::table_paiements.count == 0
        "Table des paiements vidée avec succès"
      else
        "Bizarrement, la table des paiements ne semble pas vide…"
      end
    else
      "Impossible de vider la table des paiements en ONLINE"
    end

  end

  def remove_table_paiements
    if OFFLINE
      User::table_paiements.destroy
      "Table des paiements détruite avec succès."
    else
      "Impossible de détruire la table des paiements en ONLINE. On perdrait toutes les données."
    end
  end

  def montre_table table_ref
    db_name, table_name = table_ref.split('.')
    db_path = "./database/data/#{db_name}.db"
    raise "La base `#{db_path}` est introuvable…" unless File.exist?(db_path)
    table = BdD::new(db_path).table(table_name)
    raise NotFatalError, "La table `table_name` est inconnue dans `#{db_path}`…" unless table.exist?
    # Sinon, on peut afficher la table
    show_table table
  end

  def detruire_programmes_de uref
    raise "Impossible en ONLINE, désolé" if ONLINE
    u = if uref.numeric?
      User::get(uref.to_i)
    else
      User::get_by_pseudo(uref)
    end

    raise "Impossible d'obtenir l'user avec la référence #{uref}" if u.nil?

    # On charge tout ce qui concerne Unan, on en aura
    # besoin plus bas (pour les bases de données)
    site.require_objet 'unan'

    # Destruction des paiements "1UN1SCRIPT" de l'user
    where = "user_id = #{u.id} AND objet_id = '1AN1SCRIPT'"
    nombre_paiements = User::table_paiements.count(where:where)
    User::table_paiements.delete(where:where)

    # Destruction de son dossier dans database/data/unan/user
    with_dossier_db = u.folder_data.exist? ? "détruit" : "inexistant"
    u.folder_data.remove if u.folder_data.exist?

    # Destruction de ses programmes dans la table
    where = "auteur_id = #{u.id}"
    nombre_programmes = Unan::table_programs.count(where: where)
    nombre_projets    = Unan::table_projets.count(where: where)
    Unan::table_programs.delete(where: where)
    # Destruction de ses projets dans la table
    Unan::table_projets.delete(where: where)

    "Destruction de tous les programmes de #{u.pseudo} opérée avec succès\n# Nombre paiements détruits : #{nombre_paiements}\n# Dossier database : #{with_dossier_db}\n# Nombre programmes détruits : #{nombre_programmes}\n# Nombre projets détruits : #{nombre_projets}"
  end

end #/Console
end #/Admin
end #/SiteHtml
