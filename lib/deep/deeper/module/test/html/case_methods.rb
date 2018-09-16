# encoding: UTF-8
=begin

SiteHtml::Test::Html

Pour le traitement des codes Html

=end
class SiteHtml
class TestSuite
class HTML

  include ModuleCaseTestMethods


  # has_tag
  # has_tags
  # has_tag?
  # has_tags?
  # has_not_tag
  # has_not_tags
  #
  # Message qui cherche tab avec les options
  # Produit une failure ou un succès, sauf si :evaluate est false
  # dans les options.
  def has_tag tag, options=nil, inverse=false
    if debug?
      debug "-> SiteHtml::TestSuite::Html#has_tag( tag=#{tag.inspect}, options=#{options.inspect}, inverse=#{inverse.inspect})"
    end
    options ||= Hash.new

    tag_init = tag.freeze

    # On retire toutes les options pour ne conserver que
    # les attributs qui vont être à checker dans la balise
    option_id       = options.delete(:id)
    option_class    = options.delete(:class)
    option_count    = options.delete(:count)
    option_text     = options.delete(:text) || options.delete(:content)
    option_strict   = options.delete(:strict) === true
    option_evaluate = options.delete(:evaluate)

    # Ce qui reste dans +options+ doit être SEULEMENT les attributs
    # à trouver dans la ou les balises
    # Pour la clarté, on duplique la table de hashage
    attrs = options.dup


    # On modifie +tag+ en fonction des données d'options
    # éventuelle
    {
      # Note : `pref`, ci-dessous, ne sert à rien
      id:     { pref:'#', opt: option_id     },
      class:  { pref:'.', opt: option_class  }
    }.each do |prop, dprop|
      tag = "#{tag}#{dprop[:pref]}#{dprop[:opt]}" if dprop[:opt] != nil
    end

    # On relève toutes les balises
    tags = page.css( tag )

    if debug?
      debug "  = Nombre de balises trouvées : #{tags.count}"
    end

    unless attrs.empty?
      tags = tags.select do |edom|
        is_valide = true
        attrs.each do |attr, value|
          if edom[attr.to_s] != value
            is_valide = false
            break
          end
        end
        if is_valide && debug?
          debug "  = Balise conforme par ses attributs"
        end
        is_valide
      end
    end

    if debug?
      iftestattrs = if attrs.empty?
        ""
      else
        " (après test des attributs : #{attrs.inspect})"
      end
      debug "\n= #{tags.count} TAGS CONSERVÉS#{iftestattrs} : "
      debug tags.collect{|t| t.text }.join("\n")
      debug "=/Fin TAGS CONSERVÉS"
    end

    # Si +options+ définit :text; il faut chercher le texte
    # dans les balises remontées
    nombre_iterations = if option_text
      search_text_in_tags(tags, option_text, {strict:option_strict, several: (option_count!=nil && option_count>1)})
    else
      tags.count
    end
    debug "= nombre_iterations : #{nombre_iterations}" if debug?

    ok = if option_count != nil
      nombre_iterations == option_count
    else
      nombre_iterations >= 1
    end

    debug "=== OK = #{ok.inspect}\n\n\n" if debug?

    # /fin du test
    # ---------------------------------------------------------------------

    # Pour indiquer le nombre de fois où la balise devait
    # être trouvées
    mess_count = if option_count
      " #{option_count} fois"
    else
      ""
    end

    # On construit la spécification de la balise avec ses
    # attributs recherchés
    tag_in_message = tag.dup
    unless attrs.empty?
      tag_in_message += attrs.collect{|a,v| "[#{a}=#{v}]"}.join('')
    end

    unless option_text.nil?
      exactement = option_strict ? "exactement" : "à peu près"
      tag_in_message += " contenant #{exactement} “#{option_text}”"
    end

    la_chose = case tag_init.downcase
    when "form"     then "Le formulaire"
    when "a"        then "Le lien"
    when "section"  then "La section"
    else "La balise"
    end

    # Les messages d'échec en fonction du fait qu'on demande
    # un nombre exact ou non.
    message_on_failure = if !ok
      if option_count && (option_count != nombre_iterations)
        "#{la_chose} `#{tag_in_message}` devrait exister#{mess_count} dans la page (elle existe #{nombre_iterations} fois)."
      else
        "#{la_chose} `#{tag_in_message}` devrait exister#{mess_count} dans la page."
      end
    else
      nil
    end


    # Soit on crée une évaluation, soit on retourne simplement
    # le résultat (quand options[:evaluate] == false)
    unless option_evaluate === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "#{la_chose} #{tag_in_message} existe#{mess_count}.",
        on_success_not:   "#{la_chose} #{tag_in_message} n'existe pas#{mess_count} (OK).",
        on_failure:       message_on_failure,
        on_failure_not:   "#{la_chose} #{tag_in_message} ne devrait pas exister#{mess_count}."
      ).evaluate
    else
      return ok
    end
  end
  def has_tag? tag, options=nil, inverse=false
    has_tag(tag, (options||{}).merge(evaluate: false), inverse)
  end
  def has_tags arr, options=nil
    evaluate_as_pluriel :has_tag, arr, options, inverse=false
  end
  def has_tags? arr, options=nil
    evaluate_as_pluriel :has_tag?, arr, options, inverse=false
  end
  def has_not_tag tag, options = nil
    has_tag tag, options, true
  end
  def has_not_tags arr, options=nil
    evaluate_as_pluriel :has_not_tag, arr, options, inverse=true
  end

  # ---------------------------------------------------------------------
  #   HAS_MESSAGE
  # ---------------------------------------------------------------------

  # has_message
  # has_not_message
  # has_message?
  # has_messages
  # has_not_messages
  # has_messages?
  # has_not_messages?
  def has_message mess, options = nil, inverse = false
    options ||= Hash.new
    ok = has_tag?("div#flash div.notice", options.merge!(text: mess))
    # Message supplémentaire indiquant les messages
    # flash affichés dans la page
    mess_sup = ok ? "" : messages_flash_as_human(mess)

    message_strict = if options[:strict]
      "message"
    else
      "message ressemblant à"
    end

    unless options[:evaluate] === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "La page affiche bien le #{message_strict} “#{mess}”.",
        on_success_not:   "La page n'affiche pas de #{message_strict} “#{mess}” (OK).",
        on_failure:       "La page devrait afficher un #{message_strict} “#{mess}” (#{mess_sup}).",
        on_failure_not:   "La page ne devrait pas afficher un #{message_strict} “#{mess}”."
      ).evaluate
    else
      return ok
    end
  end
  # Méthode-?
  def has_message? mess, options = nil, inverse = false
    options ||= Hash.new
    options.merge!(evaluate: false)
    has_message(mess, options, inverse)
  end
  # Méthode négative
  def has_not_message mess, options=nil
    has_message mess, options, true
  end
  # Méthode plurielle
  def has_messages arr, options=nil
    evaluate_as_pluriel :has_message, arr, options, inverse=false
  end
  def has_not_messages arr, options=nil
    evaluate_as_pluriel :has_not_message, arr, options, inverse=true
  end

  # ---------------------------------------------------------------------
  #   HAS LINK
  # ---------------------------------------------------------------------
  def has_link( href, options = nil, inverse = false )
    has_tag('a', (options || {}).merge(href: href), inverse)
  end
  def has_not_link(href, options = nil, inverse = false )
    has_link(href, options, true)
  end
  def has_link?(href, options = nil)
    has_link(href, (options || {}).merge(evaluate: true), false)
  end
  def has_not_link?(href, options = nil)
    has_link(href, (options || {}).merge(evaluate: true), true)
  end
  def has_links(arr, options = nil, inverse = false)
    evaluate_as_pluriel( :has_link, arr, options, inverse )
  end
  def has_not_link( arr, options = nil)
    has_links(arr, options, true)
  end
  def has_links?(arr, options = nil, inverse = false )
    evaluate_as_pluriel( :has_link?, arr, options, false )
  end
  def has_not_links?(arr, options = nil)
    has_links?(arr, options, true)
  end

  # ---------------------------------------------------------------------
  #   HAS ERROR
  # ---------------------------------------------------------------------

  def has_error mess, options = nil, inverse = false
    options ||= Hash.new

    options.merge!(text: mess)

    ok = has_tag?("div#flash div.error",  options)
    ok = has_tag?(".access_error",        options) if !ok
    ok = has_tag?(".main_error",          options) if !ok

    # Message supplémentaire indiquant les messages
    # flash affichés dans la page
    mess_sup = ok == !inverse ? "" : messages_flash_as_human(mess)

    message_strict = if options[:strict]
      "message d'erreur"
    else
      "message d'erreur ressemblant à"
    end

    unless options[:evaluate] === false
      SiteHtml::TestSuite::Case::new(
        tmethod,
        result:           ok,
        positif:          !inverse,
        on_success:       "La page affiche bien le #{message_strict} “#{mess}”.",
        on_success_not:   "La page n'affiche pas un #{message_strict} “#{mess}” (OK).",
        on_failure:       "La page devrait afficher le #{message_strict} “#{mess}” (#{mess_sup}).",
        on_failure_not:   "La page ne devrait pas afficher un #{message_strict} “#{mess}” (#{mess_sup})."
      ).evaluate
    else
      return ok
    end
  end
  def has_not_error mess=nil, options=nil
    mess ||= //
    has_error mess, options, inverse=true
  end
  def has_errors arr, options=nil
    evaluate_as_pluriel :has_error, arr, options, inverse=false
  end
  def has_not_errors arr, options=nil
    evaluate_as_pluriel :has_not_error, arr, options, inverse=true
  end
  def has_error? mess, options = nil, inverse = false
    options ||= Hash.new
    options.merge!(evaluate: false)
    has_error(mess, options, inverse)
  end

  # Retourne true si le code contient le div#flash qui
  # contient les messages de l'application RestSite
  def has_flash_tag?
    has_tag( 'div#flash', evaluate: false )
  end
  def has_flash_message?
    has_tag( 'div#flash div.notice', evaluate: false ) || has_tag( 'div#flash div.message', evaluate: false )
  end
  def has_flash_error?
    has_tag( 'div#flash div.error', evaluate: false )
  end

  def has_title titre, niveau=nil, options=nil, inverse=false
    options ||= Hash.new

    titre_init = if titre.instance_of?(Regexp)
      titre.to_s
    else
      titre
    end.freeze

    niveaux = niveau ? [niveau] : (1..6)

    # On cherche le titre
    found = false
    options = options.merge!(text: titre)
    niveaux.each do |niv|
      if has_tag?("h#{niv}", options)
        found = true
        break
      end
    end

    SiteHtml::TestSuite::Case::new(
      tmethod,
      result:           found == true,
      positif:          !inverse,
      on_success:       "Le titre “#{titre_init}” existe dans la page.",
      on_success_not:   "Le titre “#{titre_init}” n'existe pas dans la page (OK).",
      on_failure:       "Le titre “#{titre_init}” devrait exister dans la page.",
      on_failure_not:   "Le titre “#{titre_init}” ne devrait pas exister dans la page."
    ).evaluate
  end
  # Retourne TRUE si le titre est trouvé
  def has_title? titre, niveau=nil, options=nil, inverse=false
    options ||= Hash.new
    options.merge!(evaluate: false)
    has_title(titre, niveau, options, inverse)
  end
  def has_titles arr, options=nil
    evaluate_as_pluriel :has_title, arr, options, inverse=false
  end
  def has_titles? arr, options=nil
    evaluate_as_pluriel :has_title?, arr, options
  end
  def has_not_title titre, niveau = nil, options = nil
    has_title titre, niveau, options, true
  end
  def has_not_titles arr, options=nil
    evaluate_as_pluriel :has_not_title, arr, options, inverse=true
  end
  def has_not_titles? arr, options=nil
    evaluate_as_pluriel :has_not_title?, arr, options, inverse=true
  end

end #/Html
end #/TestSuite
end #/SiteHtml
