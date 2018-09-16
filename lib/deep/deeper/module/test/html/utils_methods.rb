# encoding: UTF-8

require 'levenshtein'

class SiteHtml
class TestSuite
class HTML



  # Cherche le texte +text+ dans les balises définies par
  # +tag+ avec les options +options+ et retourne le nombre
  # de résultats trouvés.
  #
  # +text+        {String|RegExp} Le texte à rechercher
  #
  # +options+
  #   :several    Mettre à true pour chercher le texte plusieurs
  #               seule fois (false par défaut)
  #   :strict     Si true, recherche le texte strictement dans la
  #               balise (false par défaut)
  #
  # Retourne le nombre d'occurences trouvés (noter qu'il peut).
  # y en avoir plusieurs par balise.
  def search_text_in_tag tag, text, options=nil
    search_text_in_tags page.css(tag), text, options
  end
  def search_text_in_tags tags, text, options=nil
    options ||= Hash.new

    if debug?
      debug "\n\n-> search_text_in_tags(tags, text=“#{text}”, options=#{options.inspect})"
    end

    # Le texte à trouver
    unless text.instance_of?(Regexp)
      text = if options[:strict]
        /^#{text}$/
      else
        /#{text}/i
      end
    end

    nombre_found = 0
    tags.each do |tag|
      debug "\n* Recherche de #{text.inspect} in #{tag.text.inspect}" if debug?
      nb = tag.text.scan(text).count
      debug "  = Occurrences: #{nb}" if debug?
      if nb > 0
        nombre_found += nb
        # Sauf si on a précisé qu'il fallait trouver la balise
        # plusieurs fois (pour une recherche avec :count par exemple)
        # on peut retourner le nombre qui est souvent 1 dès qu'on
        # a trouvé le texte dans une balise
        return nb unless options[:several]
      end
    end
    return nombre_found
  end


  # Retourne un texte à ajouter aux messages d'erreur pour
  # préciser les messages contenus dans la page
  #
  # Si l'argument +searched_message+ est transmis à la méthode,
  # elle fait la comparaison par Levenshtein et affiche un résultat
  # en fonction de la proximité des messages.
  # Un message dont la distance normalisée est inférieure ou égale
  # à 0.3 sera considéré comme le message certainement recherché.
  # Sinon, inférieur ou égal à 0.5, ce sera un message proche.
  # Dans les cas contraires, on affiche simplement la valeur de
  # la distance.
  # Levenshtein.normalized_distance(t1, t2)
  #
  def messages_flash_as_human searched_message = nil
    hmess = messages_flash

    # # Voir les messages affichés (flash + erreurs importantes)
    # debug "\nMessages flash = #{hmess.pretty_inspect}\n\n"

    nombre_errors       = hmess[:errors].count
    nombre_notices      = hmess[:notices].count
    nombre_main_errs    = hmess[:main].count
    nombre_access_errs  = hmess[:access].count

    mess_sup = if (nombre_errors + nombre_notices + nombre_main_errs + nombre_access_errs) == 0
      "la page n'affiche strictement aucun message"
    elsif nombre_main_errs > 0
      mainerrs = hmess[:main].collect{|m| "“#{m}”"}.join(', ')
      # # ---------------------------------------------------------------------
      # # Pour essayer une requête en dur
      # res = `curl --data "login[mail]=phil@atelier-icare.net&login[password]=19ElieSalome64" http://localhost/WriterToolbox/user/login`.force_encoding('utf-8')
      # debug "\n\n\nRES AVEC REQUETE CURL EN DUR : #{res.gsub(/</,'&lt;')}\n\n\n"
      # debug "\n\n\n"+("-"*80)+"\n\n\n"
      #
      # # ---------------------------------------------------------------------
      "la page affiche un MESSAGE D'ERREUR FATALE OU NON FATALE (note : le contenu de la page est mis en débug) : #{mainerrs}"
    elsif nombre_access_errs > 0
      accerrs = hmess[:access].collect{|m| "“#{m}”"}.join(', ')
      "la page affiche un message d'ERREUR D'ACCÈS : #{accerrs}"
    else
      errs = hmess[:errors]
      nots = hmess[:notices]
      if searched_message != nil
        errs = liste_with_levenshtein(errs, searched_message)
        nots = liste_with_levenshtein(nots, searched_message)
      else
        errs = errs.collect{|e| "“#{e}”"}
        nots = nots.collect{|e| "“#{e}”"}
      end
      errs = errs.join(', ')
      nots = nots.join(', ')
      s_errors = nombre_errors > 1 ? 's' : ''
      s_notices = nombre_notices > 1 ? 's' : ''
      m = "la page affiche "
      arr = Array::new
      arr << "le#{s_errors} message#{s_errors} d'erreur : #{errs}" unless hmess[:errors].empty?
      arr << "le#{s_notices} message#{s_notices} : #{nots}" unless hmess[:notices].empty?
      m += arr.join(' ainsi que ')
      m
    end
  end

  # Retourne la liste des messages +messages+ en indiquant leur
  # proximité avec le message +searched+ en les comparant suivant
  # la distance normalisée de Levenshtein.
  def liste_with_levenshtein messages, searched
    # searched = searched.force_encoding('utf-8')
    messages.collect do |m|
      # m = m.force_encoding('utf-8')
      d = Levenshtein.normalized_distance(searched, m).round(2)
      if d <= 0.15
        "“<strong>#{m}</strong>” (le vrai message ? - Levenshtein:#{d})"
      elsif d <= 0.3
        "“<strong>#{m}</strong>” (peut-être le message recherché - Levenshtein:#{d})"
      elsif d <= 0.5
        "“#{m}” (message proche - Levenshtein:#{d})"
      else
        "“#{m}” (#{d})"
      end
    end
  end

  # Retourne un array contenant les messages affichés dans la
  # page. Cette méthode est à appeler en cas d'erreur lorsqu'il
  # faut indiquer quels messages existent dans la page
  def messages_flash
    # debug "\n\n" + "-"*80
    # debug "\n-> messages_flash\n"
    # cont = page.css("div#flash").text.gsub(/</, '&lt;')
    # debug "page.css('div#flash') : #{cont}"
    # debug "\n\n" + "-"*80
    notices = page.css("div#flash div.notice").collect do |edom|
      edom.text
    end
    warnings = page.css("div#flash div.error").collect do |edom|
      edom.text
    end
    {
      notices:  notices,
      errors:   warnings,
      main:     message_main_error,
      access:   message_access_error
    }
  end

  def message_access_error
    @message_access_error ||= begin
      page.css('p.access_error').collect do |edom|
        edom.text
      end
    end
  end
  def message_main_error
    @message_main_error ||= begin
      page.css('p.main_error').collect do |edom|
        edom.text
      end
    end
  end

  # Méthode pour inspecter le code actuel
  def inspect
    # return unless tmethod.verbose?
    debug "\n\n"+("-"*80)+"\n\n"
    debug "=== html.inspect ==="
    debug page.inner_html.gsub(/</,'&lt;').gsub(/>/,'&gt;')
    debug "=== /html.inspect ==="
    debug "\n\n"+("-"*80)+"\n\n"
  end

  # Méthode pour afficher le message de débug
  def debug_debug
    sdeb = page.inner_html.scan(/(<section id="debug"(.*?)<\/section>)/m)[0][0]
    debug sdeb.gsub(/</,'&lt;')
  end
  alias :show_debug :debug_debug

end #/Html
end #/TestSuite
end #/SiteHtml
