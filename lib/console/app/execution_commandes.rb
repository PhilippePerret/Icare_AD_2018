# encoding: UTF-8
=begin
Extension des méthodes d'exécution des commandes console
=end
class SiteHtml
class Admin
class Console

  # Pour exécuter la line telle quelle
  def app_execute_as_is line

    case line.downcase

      # --- ICARE ---
    when /^set icarien (.*?) (inactif|actif|on|off)$/
      console.require 'icare'
      return set_icarien line

      # --- CITATION ---

    when /^new citation$/
      redirect_to 'citation/edit'
      return ''

      # --- FILMODICO ---

    when /liste? films/
      site.require_objet 'analyse'
      FilmAnalyse::films_in_table
    when /liste? filmodico/
      site.require_objet 'filmodico'
      Filmodico::films_in_table
    when /^(nouveau|new) film$/
      if OFFLINE then "ERROR : seulement en ONLINE"
      else (redirect_to "filmodico/edit"); "" end

      # --- SCENODICO ---

    when /^(nouveau|new) mot$/
      if OFFLINE then "ERROR : seulement en ONLINE"
      else (redirect_to "scenodico/edit"); "" end
    when /^(état des lieux|etat des lieux|inventory) narration$/
      redirect_to "admin/inventory?in=cnarration"
      return ""

      # --- NARRATION ---

    when /^smart tdms? narration$/
      redirect_to 'admin/smart_tdm?in=cnarration'
      return ""
    when /^narration (sortie|output|export) latex(.*?)$/
      console.require 'narration'
      sortie_latex line.sub(/^narration (sortie|output|export) latex/,'')
    when /(help|aide) livres narration/
      console.require 'narration'
      aide_pour_les_livres_narration
    when /^(recherche|search) narration$/
      redirect_to 'cnarration/search'; ""
    when /^(nouvelle|new) page narration/
      console.require 'narration'
      goto_nouvelle_page_narration
    when /^(edit|éditer) page narration (.*?)$/
      console.require 'narration'
      edit_page_narration line.downcase.sub(/^edit page narration /, '')
    when /^(open|ouvre|ouvrir) page narration (.*)$/
      console.require 'narration'
      ouvrir_fichier_texte_page_narration line.sub(/^(ouvre|ouvrir) page narration /i,'')
    when /^(creer|create) (page|chapitre|chap|sous-chapitre|schap|sous_chapitre) narration (.*?)$/
      console.require 'narration'
      creer_page_ou_titre_narration line.sub(/^(creer|create) /,'')
    when /^(check|vérifier) pages narration out$/
      console.require 'narration'
      check_pages_narration_out_tdm
    when /^balise question$/
      console.require 'narration'
      bals, retour = give_balise_of_question
      sub_log liste_built_balises(bals)
      return retour

      # --- ANALYSES DE FILM ---

    when /^film tm to timeline/i
      console.require 'analyses'
      build_timeline_from_film_tm line.sub(/^film tm to timeline/i,'').strip
    when /^(inventory|etat des lieux|état des lieux) analyses$/
      redirect_to "admin/dashboard?in=analyse"
      return ""
    when /^(build|construire) manuel (analyse|analyses|analyste)$/
      console.require 'analyses'
      build_manuel_analyste
    when /^fonctionnement analyses$/
      console.require 'analyses'
      affiche_rappel_fonctionnement
    when /^(afficher|affiche|show|montre) analyse (.+)$/
      console.require 'analyses'
      Analyses.instance.redirect_to_analyse_of(line.sub(/^(afficher|affiche|show|montre) analyse /,'').strip)
    when /^(lien|balise) analyse$/
      console.require 'analyses'
      affiche_aide_balise_analyses
    # when /^(lien|balise) analyse (.+)$/
    #   console.require 'analyses'
    #   Analyses.instance.liens_balises_vers(line.sub(/^(lien|balise) analyse /,'').strip)

      # --- PROGRAMME ÉCRIRE UN FILM/ROMAN EN UN AN ---

    when /^detruire programme /
      # Pour détruire le programme d'un auteur
      console.require 'unan_unscript'
      return unan_detruire_programme_auteur line.sub(/^detruire programme /,'').strip
    when /^unan /
      console.require 'unan_unscript'
      case line.downcase
      when /^unan send me (rapport|report)/
        return unan_simule_envoi_rapport (line.split(' ').last)
      when /^unan (build|construire|construis) manuel auteur(e|s)?$/
        return unan_build_manuel(line.split(' ').last)
      when "unan points"
        unan_affiche_points_sur_lannee
      when "unan état des lieux", "unan inventory"
        faire_etat_des_lieux_programme
      when "unan répare", "unan repare"
        reparation_programme_unan
      when /^unan (afficher|affiche|backup data|destroy|retreive data) table (pages_cours|exemples|absolute_works|projets|absolute_pdays|programs|questions|quiz)$/
        return "Ces commandes ne sont plus utilisables."
      else
        nil # pour chercher la commande autrement
      end

    else
      nil # pour chercher la commande autrement
    end
  end


  # Exécute une commande dont le dernier mot est
  # une variable
  # +sentence+  La commande avant la variable
  # +last_word+ Le dernier mot, donc la valeur de la variable
  def app_execute_as_last_is_variable sentence, last_word

    case sentence
    when /^pages narration niveau/i
      console.require 'narration'
      ( liste_pages_narration_of_niveau last_word )
    # ---------------------------------------------------------------------
    # PROGRAMME ÉCRIRE UN FILM/ROMAN EN UN AN
    # ---------------------------------------------------------------------
    when /^unan (nouveau|nouvelle)/i
      ( goto_section "unan_new_#{last_word}" )
    when 'unan init program for'
      ( init_program_1an1script_for last_word )
    when 'detruire programmes de'
      ( detruire_programmes_de last_word )

    else
      nil # Pour essayer de trouver la commande autrement
    end
  end

  # Exécution comme une expression régulière propre à
  # l'application
  def app_execute_as_regular_sentence line
    if (found = line.match(/^(?:balise|lien) (livre|film|analyse|mot|page|user|question|checkup) (.*?)(?: (ERB|erb))?$/).to_a).count > 0
      ( main_traitement_balise found[1..-1] )
    elsif ( found = line.match(/^set benoit to pday ([0-9]+)(?: with (\{(?:.*?)\}))?$/).to_a).count > 0
      console.require 'unan_unscript'
      change_pday_benoit found[1].to_i, eval(found[2] || 'nil')
    else
      return false # pour chercher la commande autrement
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
