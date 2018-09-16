# encoding: UTF-8
=begin
Essai pour des tests particuliers
=end

class SiteHtml
class TestSuite

  def display_resultat
    log resultat
  end

  def resultat
    @resultat ||= begin

      # Construire les éléments d'affichage
      details_test

      color = nombre_failures == 0 ? 'green' : 'red'
      s_failures = nombre_failures > 1 ? "s" : ""
      resume = "#{nombre_failures} failure#{s_failures} #{nombre_success} success".in_span(class: color)

      (
        resume            +
        informations      +
        @detail_failures  +
        @detail_success   +
        disp_infos_test
      )
    end
  end

  def informations
    infs = ""
    unless @files_out.nil?
      files_and_raisons = files_out.collect do |dout|
        "#{dout[0]} (#{dout[1]})"
      end.join(', ')
      infs << "Fichiers exclus : #{files_and_raisons}"
    end
    infs != "" || ( return "" )
    infs.in_div(class:'small')
  end

  def disp_infos_test
    s_tests = infos[:nombre_tests] > 1 ? 's' : ''
    s_files = infos[:nombre_files] > 1 ? 's' : ''
    laps = (infos[:end_time] - infos[:start_time]).round(4)
    "<hr>" + (
      "#{infos[:nombre_files]} fichier#{s_files}" +
      " in #{folder_test_path}"
      " | #{infos[:nombre_tests]} test#{s_tests}"+
      " | #{infos[:nombre_cas]} cas"+
      " | durée : #{laps}" +
      " | #{online? ? 'ONLINE' : 'OFFLINE'}" +
      " | backups: #{infos[:duree_db_backup]} / #{infos[:duree_db_unbackup]}" +
      " |"
    ).in_div(id:'test_infos')
  end

  def nombre_failures;  @nombre_failures end
  def nombre_success;   @nombre_success  end

  # Méthode créant l'affichage des succès et des failures
  # on passant fichier test après fichier test
  def details_test
    nombre_total = {success: 0, failure: 0}
    messages_str = {success: "", failure: ""}

    nombre_total_success  = 0
    nombre_total_failures = 0
    success_messages = ""
    failure_messages = ""

    @itestfile = 0

    # Boucle sur chaque fichier-test
    test_files.each do |testfile|

      nombre = {
        success:  testfile.success_tests.count,
        failure:  testfile.failure_tests.count
      }
      nombre_total[:success] += nombre[:success]
      nombre_total[:failure] += nombre[:failure]

      # Si le fichier n'a aucun succès ni aucune failure, c'est
      # qu'aucun test n'a été joué. => On le passe.
      next if (nombre[:success] + nombre[:failure]) == 0

      # La ligne principale décrivant le fichier courant.
      div_filepath = testfile.line_output( @itestfile += 1 )

      filetest_messages = { failure: nil, success: nil }
      [:failure, :success].each do |ktype|
        filetest_messages[ktype] = messages_of_tmethods_of_tfile( testfile, ktype )
        # On ajoute les messages, sauf s'il sont vides
        if nombre[ktype] > 0
          messages_str[ktype] += (div_filepath + filetest_messages[ktype]).in_div(class:'atests').in_div(class:"tfile #{ktype[0..2]}")
        end
      end

    end #/Fin de boucle sur chaque fichier-test

    # Définir les variables d'instance qui vont contenir les
    # valeurs à prendre en compte
    @nombre_failures = nombre_total[:failure]
    @nombre_success  = nombre_total[:success]

    # Renseigner le nombre total de tests
    infos[:nombre_tests] = nombre_total[:success] + nombre_total[:failure]

    @detail_failures = if nombre_total[:failure] > 0
      "Failures".in_h4(class:'red') + messages_str[:failure]
    else
      ""
    end
    @detail_success = if nombre_total[:success] > 0
      "Success".in_h4(class:'green') + messages_str[:success]
    else
      ""
    end
  end

  # Affichages de toutes les test-méthodes de type +type+,
  # i.e. :success ou :failure, du fichier-test +__tfile+
  # En fonction des options, on affiche ou non tous les
  # messages des case-méthodes.
  def messages_of_tmethods_of_tfile __tfile, type
    __tfile.send("#{type}_tests".to_sym).collect do |tmethod|
      verbose = if type == :failure
        true
      else
        ( tmethod.verbose? || tmethod.quiet? === false ) ||
        ( __tfile.verbose?   || __tfile.quiet? === false )   ||
        ( verbose?         || quiet? === false )
      end
      infos[:nombre_cas] += tmethod.messages_count
      c = tmethod.full_libelle_output
      c << tmethod.messages_output if verbose || !tmethod.success?
      c
    end.join('')
  end

end #/TestSuite
end #/SiteHtml
