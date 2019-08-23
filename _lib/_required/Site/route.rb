# encoding: UTF-8
=begin
Class SiteHtml
--------------
Méthodes propres au traitement de la route
=end
class SiteHtml

  # = main =
  #
  # Exécution de la route, si elle est définie
  #
  # C'est la première méthode qui est appelée quand on vient
  # de l'index (cf. output.rb).
  #
  # Noter que ce n'est pas ici qu'est géré une mauvaise route (une
  # route conduisant nulle page). Une mauvaise route est gérée dans
  # la méthode Page#content_route dans le fichier page/vues.rb
  #
  def execute_route
    app.benchmark('-> SiteHtml#execute_route')

    # Appel ajax avec le paramètre `route` définissant la route
    # à suivre.
    if site.ajax? && param(:route)
      reg = /([a-zA-Z_]+)(?:\/([0-9]+))?\/([a-zA-Z_]+)(?:\?in=([a-zA-Z_]+))?/
      # tout, objet, objet_id, method, context = param(:route).match(reg).to_a
      droute = param(:route).match(reg).to_a
      send(:set_params_route, *droute[1..-1])
    end

    if param(:__o)

      # Sinon, on crée une instance route, qui va posséder toutes
      # les données des paramètres (context, objet, objet_id et
      # method)
      @current_route = iroute = Route.new

      debug "\nObjet    = #{iroute.objet.inspect}"     +
            "\nObjet ID = #{iroute.objet_id.inspect}"  +
            "\nMethod   = #{iroute.method.inspect}"    +
            "\nContext  = #{iroute.context.inspect}"
    end

    # Si l'utilisateur est identifié, on mémorise sa
    # route et sa date de dernière connexion.
    if user.identified? && !user.moteur_recherche?
      app.benchmark('--> user.set_last_connexion')
      user.set_last_connexion
      app.benchmark('<-- user.set_last_connexion')
    end

    # Si aucun objet n'est défini dans la route, on peut s'en
    # retourner immédiatement.
    # Noter qu'on doit le faire ici , après `set_last_connexion`
    # pour que la dernière connexion de l'user soit prise en
    # compte même lorsque __o n'est pas défini.
    return if param(:__o).nil?

    # La méthode qui va charger tout ce qui est défini par rapport
    # à la route donnée. Par exemple, si la route est "tool/list",
    # la méthode va chercher le dossier `./_objet/tool/lib/required`
    # et s'il le trouve elle va charger tous ses éléments dont les
    # modules ruby qui définiront PEUT-ÊTRE la classe Tool et la
    # méthode de classe ::list. Si la route définit le contexte
    # `unan/program' (par exemple `abs_pday/cal?in=unan/program`),
    # la méthode va tenter de charger :
    #   - le dossier ./_objet/unan/lib/required s'il existe
    #   - le dossier ./_objet/unan/program/lib/required s'il existe
    app.benchmark('--> iroute.load_required')
    iroute.load_required
    app.benchmark('<-- iroute.load_required')

    # On va requérir aussi toutes les choses qui peuvent
    # correspondre à la vue demandée. Par exemple, si la route
    # 'forum/messages' est demandée, on va pouvoir charger les
    # modules ruby 'forum/messages.rb', css 'forum/messages.css'
    # et javascript 'forum/messages.js'.
    app.benchmark('--> iroute.load_per_vue')
    iroute.load_per_vue
    app.benchmark('<-- iroute.load_per_vue')

    # Ensuite, si une méthode est définie pour un objet
    # (et un contexte) défini, il faut l'appeler. La méthode
    # permet aussi, indirectement, de définir la classe et
    # la sous-classe (si contexte) correspondant à la route
    app.benchmark('--> iroute.method_call')
    iroute.method_call
    app.benchmark('<-- iroute.method_call')

    # debug "<- SiteHtml::execute_route"

    # ---------------------------------------------------------------------
    #   Gestion de toutes les erreurs possibles
    # ---------------------------------------------------------------------
  rescue SectionInterditeError => e
    # Barrière raise_unless( condition )
    page.content= page.error_unless_condition
  rescue ErrorUnidentified => e
    # Barrière raise_unless_identified
    page.content = page.error_unless_identified
  rescue ErrorNoAdmin => e
    # Barrière raise_unless_admin
    page.content= page.error_unless_admin
  rescue ErrorNotOwner => e
    # Barrière raise_unless_owner
    page.content= page.error_unless_owner(e.message)
  rescue NonFatalError => err
    page.content= page.error_non_fatale(err)
  rescue Exception => e
    debug e
    page.content= page.error_standard(e)
  ensure
    app.benchmark('<- SiteHtml#execute_route')
  end

  # Retourne true si la route +route+ est égale à la route
  # courante
  def current_route? route_checked
    route_checked != '' || route_checked = 'site/home'
    curroute = self.current_route ? self.current_route.route : 'site/home'
    curroute == route_checked
  end
  alias :route? :current_route?

  # Retourne true si on se trouve sur la page d'accueil
  def home_page?
    current_route?('')
  end

  # Un raccourci pour obtenir l'instance courante
  # de la route à l'aide de `site.objet` ou `site.instance`
  def objet
    @objet ||= self.current_route.instance
  end
  alias :instance :objet

  # {SiteHtml::Route} Instance de la route courante
  attr_reader :current_route

  def route
    @route ||= SiteHtml::Route.new
  end


  # Une redirection
  # ---------------
  # La redirection correspond tout simplement à modifier les paramètres
  # de la route (__o, __i etc.) et à exécuter la route une nouvelle fois
  #
  def redirect_to rut
    app.benchmark('-> SiteHtml#redirect_to')
    # Premier traitement : les raccourcis
    rut =
      case rut
      when :last_page, :last_route
        app.session['last_route'] || param(:redirect) || :home
      when :signin  then 'user/login'
      when :signup  then 'user/signup'
      when :home    then :home # cf. ci-dessous
      else
        if param(:redirect) then
          param(:redirect)
        else
          rut
        end
      end

    # Barrière pour empêcher de rediriger vers la page courante lorsqu'il
    # y a une erreur qui se reproduit 10 fois et ramène à cette redirection.
    @nombre_redirections ||= 1
    if site.current_route && rut == site.current_route.route && @nombre_redirections > 10
      "Redirection corrigée (#{rut}) vers accueil"
      rut = 'site/home'
    end

    @nombre_redirections += 1

    # Traitement spécial pour les routes 'user/login' ou
    # 'user/signup'. Il faut mettre dans le paramètre
    # backto la route actuelle pour y renvoyer l'user
    # après son identification réussie.
    if rut == 'user/login'
      route_courante =
        if site.current_route.nil?
          nil
        else
          site.current_route.route
        end
      param(backto: route_courante)
      route_courante.nil? || debug("param(:backto) mis à #{route_courante.inspect}")
    end

    # On reset complètement les valeurs __o etc. qui
    # définissent les routes.
    set_params_route

    # debug "rut après premier traitement : #{rut}"

    # Traitement réel de la route
    begin
      case rut
      when :home
        obj, obj_id, meth, cont = nil, nil, nil, nil
      else
        tout, obj, obj_id, meth, cont = rut.match(/^([a-z_]+)(?:\/([0-9]+))?\/([a-z_]+)(?:\?in=([a-z_]+))?$/).to_a
      end
    rescue Exception => e
      debug "#ERREUR #{e.message}"
      debug e.backtrace.join("\n")
      obj, obj_id, meth, cont = nil, nil, nil, nil
    end
    set_params_route obj, obj_id, meth, cont
    execute_route
    app.benchmark('<- SiteHtml#redirect_to')
    return false # pour interrompre l'exécution précédente
  end

  def set_params_route o = nil, i = nil, m = nil, c = nil
    @current_route = nil
    param(:__o  => o)
    param(:__i  => i)
    param(:__m  => m)
    param(:in   => c)
  end


  # ---------------------------------------------------------------------
  #   Classe SiteHtml::Route
  # ---------------------------------------------------------------------
  class Route
    class << self

      # Retourne la dernière route
      # @usage site.route.last
      def last
        app.session['last_route']
      end

    end # << self

    # ---------------------------------------------------------------------
    #   Instance SiteHtmlRoute
    #
    #   Donc une route du site, la route courante (mais qui peut être
    #   remplacée par une re-direction)
    #
    # ---------------------------------------------------------------------

    # ---------------------------------------------------------------------
    #   Méthodes utilitaires
    # ---------------------------------------------------------------------

    # Pour pouvoir utiliser la syntaxe `site.route` dans un
    # string et toujours retourner une valeur, même lorsqu'aucune
    # route n'est définie
    def to_str
      route.nil_if_empty || "site/home"
    end

    # Méthode qui charge, les choses utiles en fonction de la route demandée.
    # Les choses chargées doivent se trouver dans un dossier 'lib/required'
    # dans le dossier de la chose à charger.
    # Note : Il s'agit des fichiers ruby, css et javascript
    def load_required
      # debug "-> Route::load_required"
      all_folders_lib_required.each do |dossier|
        next if dossier.nil? || false == dossier.exist?
        site.require_all_in dossier
        # dossier.require
        # page.add_css        Dir["#{dossier}/**/*.css"]
        # page.add_javascript Dir["#{dossier}/**/*.js"]
      end
    end

    # Liste de tous les dossiers 'lib/required' qu'il est
    # POSSIBLE de requérir en fonction du fait qu'un contexte
    # est défini ou non.
    # Noter que c'est dans la méthode précédente qu'on regardera
    # si le dossier existe
    # Noter que l'ordre est important, pour pouvoir surclasser
    # certaines méthodes
    def all_folders_lib_required
      # debug "-> Route::all_folders_lib_required"
      @all_folders_lib_required ||= begin
        folders = Array.new
        # contexte est défini)
        folders << folder_required_from_route
        unless context.nil?
          # Le dossier ./_objet/<context>/<objet>/lib/required
          folders << folder_required_with_context
          # Le dossier ./_objet/<context>/lib/required et tous les
          # mots du contexte, c'est-à-dire, si le contexte est
          # 'mot1/mot2' alors on cherche :
          #   ./_objet/mot1/lib/required
          #   ./_objet/mot1/mot2/lib/required
          folders += folders_required_of_context
        end
        # Pour le donner
        folders
      end
    end

    # Tous les dossier lib/required possible en fonction du
    # contexte défini (on ne doit appeler cette méthode qui si
    # un contexte est défini)
    def folders_required_of_context
      @folders_required_of_context ||= begin
        curpath = Array.new
        context.split('/').collect do |folder_name|
          curpath << folder_name
          site.folder_objet + "#{File.join(*curpath)}/lib/required"
        end
      end
    end

    # Chargement des fichiers ruby, css et javascript en fonction
    # de la vue demandée par la route.
    # Noter qu'on n'utilise pas la méthode `output` qui renverrait
    # le code de la vue (même si ça ne serait pas gênant en soit, mais
    # ça doublerait la construction de la page)
    def load_per_vue
      # debug "-> Route::load_per_vue (instance_vue = #{instance_vue.path})"
      instance_vue.require_all
    end

    # Appel de la méthode si elle est définie dans les
    # paramètres de la route et si elle existe.
    # Il faut également que l'objet correspondant à la
    # route existe, ce qui n'est pas obligatoirement le
    # cas, un fichier vue pouvant être appelé sans objet
    # réel.
    # Noter que si c'est un objet propre à l'application,
    # il doit être impérativement défini dans le dossier
    # '_lib/_required' de l'objet pour pouvoir être chargé
    # avant l'appel de cette méthode.
    #
    # On n'appelle pas cette méthode si la méthode de l'url
    # est 'new'
    def method_call
      (method_sym.nil? || method_sym == :new) && return
      if sujet.respond_to?(method_sym)
        debug "[site.method_call] Appel de la méthode automatique #{method_sym.inspect}"
        sujet.send(method_sym)
      end
    end

    # ---------------------------------------------------------------------
    #   Propriétés fixes
    # ---------------------------------------------------------------------
    # Les propriétés de la route, héritées des paramètres
    def objet       ; @objet      ||= param(:__o)           end
    def objet_cam   ; @objet_cam  ||= objet.camelize        end
    def objet_id_s  ; @objet_id_s ||= param(:__i)           end
    def method_s    ; @method_s   ||= param(:__m)           end
    alias :method :method_s
    def objet_id    ; @objet_id   ||= param(:__i).to_i_inn  end
    def method_sym  ; @method_sym ||= get_method_sym        end
    def context     ; @context    ||= param(:in)            end


    # La route reconstituée
    def route
      @route ||= begin
        route_sans_context.to_s + (context.nil? ? "" : "?in=#{context}")
      end
    end

    # La route, sans le contexte (i.e. sans querystring ?in=...)
    def route_sans_context
      @route_sans_context ||= File.join(*[objet,objet_id_s,method_s].compact)
    end

    # La vue, mais seulement si elle existe
    # Noter que des fichiers attachés à la vue (ruby, css, js) peuvent
    # exister sans que la vue existe.
    def vue
      @vue ||= ( instance_vue.exist? ? instance_vue : nil )
    end

    # L'instance Vue, que la vue existe ou non. Elle est
    # utile, par exemple, pour charger les éventuelles js,
    # ruby, etc.
    def instance_vue
      @instance_vue ||= Vue.new(segment_path)
    end

    # ---------------------------------------------------------------------
    #   Propriétés volatiles
    # ---------------------------------------------------------------------

    # Le “sujet” de la route est la classe ou l'instance qui est visée
    # par la route. Ou NIL si la classe (ou l'instance) l'existe pas.
    # Par exemple, la route `user/list` a pour sujet la classe `User`.
    # La route `user/12/profil` a pour sujet l'instance User d'id 12.
    # La route `sujet/12/destroy?in=forum` a pour sujet l'instance
    # Forum::Sujet d'identifiant #12.
    # Ce sujet sert notamment à savoir ce qu'il faut binder à une vue
    # en fonction de la route.
    def sujet
      @sujet ||= ( instance || classe )
    end

    # La classe correspondant à la route. Elle peut être :
    #   Context::Objet::    s'il y a un contexte
    #   Objet::             S'il n'y a pas de contexte
    # RETURN la classe ou NIL si elle n'existe pas
    def classe
      @classe ||= begin
        if context != nil
          if Object.constants.include?(context.camelize.to_sym)
            # debug "[SiteHtml::Route#classe] Un contexte est défini, connu : #{context.camelize}"
            main_class = Object.const_get(context.camelize)
            if main_class.constants.include?(objet_cam.to_sym)
              main_class.const_get(objet_cam) # p.e. Forum::Message
            else
              nil
            end
          else
            nil
          end
        else
          if Object.constants.include?(objet_cam.to_sym)
            Object.const_get(objet_cam)
          else
            nil
          end
        end
      end
    end

    # L'instance demandée, si objet_id est défini et que la
    # classe existe.
    def instance
      @instance ||= begin
        if objet_id.nil? || classe.nil? || classe.name == "Admin" || (defined?(classe::NO_INSTANCIATION_BY_URL) && classe::NO_INSTANCIATION_BY_URL)
          nil
        else
          begin
            class_method = classe.respond_to?(:get) ? :get : :new
            classe.send( class_method, objet_id )
          rescue Exception => e
            error "Impossible d'instancier l'objet avec #{classe}::#{class_method}, malheureusement : #{e.message}"
            nil
          end
        end
      end
    end
    # ---------------------------------------------------------------------
    #   Propriétés de path
    # ---------------------------------------------------------------------
    # Par exemple 'user/edit' si la route est user/12/edit
    # Ou 'forum/message/destroy' si la route est
    # message/12/destroy?in=forum
    def segment_path
      @segment_path ||= File.join(*[context,objet,method_s].compact)
    end

    # Path dans le dossier objet
    # C'est soit le context soit l'objet qui le définit
    def path_in_objet
      @path_in_objet ||= site.folder_objet + (context || objet)
    end

    # Dossier lib/required (dans ./_objet/<objet>/)
    def folder_required
      @folder_required ||= folder_lib + 'required'
    end

    # Dossier lib/required, mais si un contexte est défini. Dans
    # ce cas, le dossier peut se trouver dans :
    # ./_objet/<context>/<objet>/lib/required
    def folder_required_with_context
      @folder_required_with_context ||= begin
        unless context.nil?
          site.folder_objet + "#{context}/#{objet}/lib/required"
        end
      end
    end

    def folder_required_from_route
      @folder_required_from_route ||= folder_lib_from_route + 'required'
    end
    # Dossier lib de la route seule, même si un contexte
    # est défini
    def folder_lib_from_route
      @folder_lib_from_route ||= site.folder_objet + "#{objet}/lib"
    end

    # Dossier lib de la route (d'après le contexte s'il est
    # défini ou d'après la route seule dans le cas contraire)
    def folder_lib
      @folder_lib ||= path_in_objet + 'lib'
    end

    private
      def get_method_sym
        m = param(:__m)
        return nil if m.nil?
        m.to_sym
      end
  end
end
