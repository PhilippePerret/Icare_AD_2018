# encoding: UTF-8
=begin
Méthodes pour les vues de la classe Page (singleton)
=end
class Page

  attr_reader :added_css
  attr_reader :added_javascript

  attr_accessor :fatal_error

  # = main =
  #
  # Méthode appelée juste après l'exécution de la route
  #
  # Il faut "précharger" l'entête et le contenu de la page pour
  # définir toutes les choses avant d'appeler les méthodes qui
  # vont charger les css, les js, les messages, etc.
  # Cette méthode prédéfinit donc `header` et `content`
  def prebuild
    return if site.ajax?
    app.benchmark('-> Page#preload')
    footer
    content
    unless fatal_error.nil?
      @content = page.error_standard(fatal_error)
    end
    app.benchmark('<- Page#preload')
  rescue Exception => e
    @content = page.error_standard(e)
  end


  # {StringHTML} Retourne le code HTML pour l'entête du
  # site. C'est le code qui se trouve dans le fichier :
  # _view/gabarit/header.erb
  def header
    @header ||= begin
      Vue.new('header', site.folder_gabarit).output
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME D'HEADER : #{e.message}]"
    end
  end

  def footer
    @footer ||= begin
      Vue.new('footer', site.folder_gabarit).output
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE FOOTER : #{e.message}]"
    end
  end

  # La page d'accueil, spéciale
  def home
    Vue.new('home', (site.folder_objet+'site')).output
  end

  def content
    @content ||= begin
      (site.folder_gabarit+'page_content.erb').deserb( site.objet_binded.respond_to?(:bind) ? site.objet_binded : nil )
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE CONTENT : #{e.message}]"
    end
  end

  # Définir le contenu à l'aide de `page.content = ...`
  # Pour le moment, seulement utilisé pour les protections de sections
  # et de modules
  # Noter que c'est @content_route qui est défini (cf. plus bas) pour
  # garder le code d'affichage dans un section#content
  # (JE NE COMPRENDS PAS LE MESSAGE CI-DESSUS...)
  def content= value
    @content_route = value
  end

  # Si une route est définie, contenant au moins 'objet' et 'method'
  # la vue _objet/<objet>/<methode>.erb, si elle existe, est chargée
  #
  # Si la route n'est pas définie ou qu'elle est mauvaise, la méthode
  # retourne NIL ce qui provoque le chargement de la page d'accueil.
  #
  def content_route
    @content_route ||= begin
      if site.current_route
        if site.current_route.vue
          site.current_route.vue.output
        else
          # C'est ici qu'on passe en cas de mauvaise route.
          (site.folder_error_pages + 'error_unknown_route.erb').deserb()
        end
      else
        # La page d'accueil du site
        nil
      end
    rescue Exception => e
      self.fatal_error = e
      "[PROBLÈME DE CONTENT_ROUTE : #{e.message}]"
    end
  end

  # Pour charger une vue
  #
  # @syntaxe    page.view(<file name|affixe>, <dossier objet>, <bindee>)
  #
  # Note : avec la version de 2019, +relpath+ peut être un nom de dossier
  # qui contient un fichier erb de même affixe. Par sécurité, on teste même
  # les fichiers contenant '.erb' à la fin pour voir s'ils n'ont pas été
  # remplacés par des dossiers. Cette opération a été faite pour simplifier
  # le rangement, en rassemblant dans un même dossier tous les fichiers .css,
  # .sass, .js, .erb de même affixe.
  #
  def view relpath, dossier = nil, bindee = nil
    dossier, relpath = Vue.normalize(dossier, relpath)
    Vue.new(relpath, dossier, bindee).output
  end
  alias :vue :view

  # {StringHTML} Retourne le code de la vue debug.erb
  # Ne pas confondre avec le débug qui se construit avec la
  # méthode handy `debug` et qui est construit dans App/debug.rb
  def section_debug
    (site.folder_gabarit+'debug/debug.erb').deserb( site )
  end

  def add_css arr_css
    if arr_css.instance_of?(String) && File.directory?(arr_css)
      arr_css = Dir["#{arr_css}/**/*.css"]
    end
    arr_css = [arr_css] unless arr_css.nil? || arr_css.instance_of?(Array)
    return if arr_css.nil? || arr_css.empty?
    @added_css ||= Array::new
    @added_css += arr_css
    # app.debug.add "@added_css: #{@added_css.inspect}"
  end

  def add_javascript arr_js
    if arr_js.instance_of?(String) && File.directory?(arr_js)
      arr_js = Dir["#{arr_js}/**/*.js"]
    end
    arr_js = [arr_js] unless arr_js.nil? || arr_js.instance_of?(Array)
    return if arr_js.nil? || arr_js.empty?
    @added_javascript ||= Array::new
    @added_javascript += arr_js
    # debug "@added_javascript: #{@added_javascript.inspect}"
  end

end
