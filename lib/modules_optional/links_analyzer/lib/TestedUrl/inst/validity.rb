# encoding: UTF-8
=begin
  Module de méthodes checkant la validité de la page
=end
class TestedPage

  # Méthode principale checkant la validité de la
  # page.
  # Il faut définir la méthode check_if_valide dans le module
  # app.rb pour chaque application
  def valide?
    if @is_valide === nil
      if false == format_url_valide?
        # Avant tout, il faut que l'URL soit valide, par exemple qu'elle
        # ne soit pas entourée de mauvais guillemets
        @is_valide = false
        error "URL INVALIDE DANS SA FORME (#{@errors_format_url.join(', ')})"
      elsif url_with_ancre?
        # Check d'une URL avec une ancre, la page courante doit
        # contenir l'ancre spécifiée
        @is_valide = self.page_has_anchor?(url_anchor)
        @is_valide || error("ANCRE INTROUVABLE : #{url_anchor}")
      elsif is_ancre?
        # Check d'une ancre seule. Le code de la page doit posséder
        # l'ancre spécié, soit sous forme d'un <a name> soit sous forme
        # d'élément d'identifiant correspondant à l'ancre.
        #
        # Note : Le `referer` ci-dessous peut paraitre étrange mais il
        # a été vérifié et il est bon (la route courante est une ancre seule,
        # un lien enregistré alors qu'on analysait la page `referer`)
        @is_valide = referer.page_has_anchor?(ancre_of_route)
        @is_valide || error("ANCRE INTROUVABLE : #{ancre_of_route.inspect}")
      elsif hors_site?
        # Pour une page hors site, il suffit que l'header retourne
        # un code correct, donc 200 ou 3xx pour que ce soit bon
        # Une analyse plus approfondie peut être faite si le retour
        # est 403
        @is_valide = page_hors_site_valide?
        @is_valide || error("STATUS HTML RETOURNÉ : #{html_status}")
      else
        # Check de la validité de la page URL spécifié
        # C'est ici que l'application peut définir elle-même en quoi
        # une page est valide, mais elle peut déjà le faire au travers
        # de la donnée DATA_ROUTES qu'il faut donc analyser d'abord si
        # elle est définie
        @valide_on_gene = check_if_valide_general
        @valide_for_app = check_if_valide_for_app
        @is_valide = @valide_on_gene && @valide_for_app
      end
    end
    @is_valide
  end

  # Premier check de la page une fois tous les premiers checks sur la
  # route (url) opérés.
  # Note : Ça s'appelle '_general', mais cette méthode dépend aussi des
  # données de l'application.
  # TODO: Au final, dans l'idéal, il ne faudrait que la donnée DATA_ROUTES
  # pour définir ce qui constitue une page valide.
  #
  # Ce check n'est nécessaire que si des DATA_ROUTES sont définis.
  #
  # Elle retourne TRUE en cas de succès (ou d'absence de test à faire)
  # et false dans le cas contraire, en renseignant la propriété @errors de
  # la route testée
  def check_if_valide_general
    defined?(DATA_ROUTES) || (return true)
    resultat = true
    if DATA_ROUTES.key?(:context) && DATA_ROUTES[:context].key?(context)
      droute = DATA_ROUTES[:context][context]
    end
    if DATA_ROUTES.key?(:objet) && DATA_ROUTES[:objet].key?(objet)
      droute = DATA_ROUTES[:objet][objet]
      if droute.key?(:has_tag) || droute.key?(:has_tags)
        has_tags = Array.new
        has_tags << [ droute[:has_tag] ] if droute.key?(:has_tag)
        has_tags += droute[:has_tags]   if droute.key?(:has_tags)
        unknow_tag = false
        has_tags.each do |has_tag|
          if matches?(*has_tag)
            # puts "La balise #{has_tag.inspect} a été trouvée."
            next
          else
            # La balise est inconnue
            unknow_tag = true
            error "Balise #{has_tag.inspect} introuvable"
          end
        end
        # /Fin de boucle sur toutes les balises attendues
        resultat = resultat && false == unknow_tag
      end
    end
    return resultat
  end

  # Return TRUE si le code de la page courante contient le tag
  # +tagname+ avec les options +tagoptions+ (qui peuvent contenir
  # :with, :text, :count etc.)
  #
  # +tagname+ peut être "div" ou "div#sonid", c'est le tagname mis
  # dans have_tag en RSpec
  #
  def matches? tagname, tagoptions = nil
    havetag =
      if tagoptions
        RSpecHtmlMatchers::HaveTag.new(tagname, tagoptions)
      else
        RSpecHtmlMatchers::HaveTag.new(tagname)
      end
    havetag.matches?(raw_code)
  end

  # Retourne true si la page définit l'ancre +ancre+
  def page_has_anchor? ancre
    self.matches?('a', with:{name: ancre}) || self.matches?('*', with: {id: ancre})
  end

  # Ancre contenue par la route
  def ancre_of_route
    @ancre_of_route ||= route_init.split('#').last
  end

  #
  def page_hors_site_valide?
    return true if route.match(/\.wikipedia\./)
    begin
      status_ok = html_status >= 200 && html_status <= 307
      raise if false == status_ok && route.start_with?('https')
    rescue Exception => e
      # Pour les routes https, il faut faire une vérification plus profonde
      # car elles peuvent ne pas renvoyer de bonne valeur si elles sont
      # sécurisées
      @route = route.sub(/^https/,'http')
      @html_status = nil
      retry
    end
    return status_ok
  end


  # Retourne true si l'url est valide dans sa forme et false
  # dans le cas contraire.
  # Renseigne @errors_format_url avec les problèmes rencontrés.
  def format_url_valide?
    @errors_format_url = Array.new
    @route != nil || (return false)
    if @route.match(/^("|'|“)/) || @route.match(/("|'|”)$/)
      @errors_format_url << "Mauvais guillemets autour de l'URL"
    end

    return @errors_format_url.count == 0
  end

end #/TestedPage
