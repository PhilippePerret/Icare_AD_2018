# encoding: UTF-8
=begin

Class Vue

=end
class Vue

  # Chemin relatif à la vue, depuis le dossier '_objet'
  attr_reader :relpath
  attr_reader :folder

  # Si +folder+ est fourni, ça doit être un SuperFile

  def initialize relpath, folder = nil, bindee = nil
    folder, relpath = Vue.normalize(folder, relpath)
    @relpath = relpath
    @folder  = folder || site.folder_objet
    @bindee  = bindee
    # Pour pouvoir retrouver rapidement une vue actuellement affichée,
    # on indique son path dans le débug
    # debug "---> vue “#{path}” (@already_required: #{@already_required.inspect})"
  end

  # ---------------------------------------------------------------------
  # Méthodes

  # Retourne le code déserbé de la vue (elle doit exister et on doit
  # avoir testé son existence avant d'appeler cette méthode)
  def output
    require_all unless @already_required
    path.deserb bindee
  end

  # ---------------------------------------------------------------------
  #   Requires méthodes

  # Méthode qui requiert tout ce qui concerne la vue ou le
  # partiel
  def require_all
    return if @already_required == true
    require_ruby
    require_css
    require_javascript
    @already_required = true
  end

  # Cf. N0005
  def require_ruby
    path_ruby.require if path_ruby.exist?
  end
  # Cf. N0005
  def require_css
    page.add_css([path_css.to_s]) if path_css.exist?
    page.add_css([path_alt_css.to_s]) if path_alt_css.exist?
    page.add_css(css_in_a_folder) if css_in_a_folder
  end
  # Cf. N0005
  def require_javascript
    page.add_javascript([path_js.to_s]) if path_js.exist?
    page.add_javascript([path_alt_js.to_s]) if path_alt_js.exist?
    page.add_javascript(js_in_a_folder) if js_in_a_folder
  end

  # ---------------------------------------------------------------------
  #   Méthodes de path

  def path_ruby     ; @path_ruby      ||= path_ext('rb')      end
  def path_css      ; @path_css       ||= path_ext('css')     end
  def path_js       ; @path_js        ||= path_ext('js')      end
  def path_alt_css  ; @path_alt_css   ||= path_alt_ext('css') end
  def path_alt_js   ; @path_alt_js    ||= path_alt_ext('js')  end

  # Les fichiers css pouvant se trouver dans un dossier css
  def css_in_a_folder
    @css_in_a_folder ||= begin
      if path_folder_css.exists?
        Dir["#{path_folder_css}/**/*.css"]
      end
    end
  end
  def js_in_a_folder
    @js_in_a_folder ||= begin
      if path_folder_js.exists?
        Dir["#{path_folder_js}/**/*.js"]
      end
    end
  end
  # Le dossier pouvant contenir des fichiers css
  def path_folder_css
    @path_folder_css ||= folder_parent+"#{affixe}/css"
  end
  # Le dossier pouvant contenir des fichiers js
  def path_folder_js
    @path_folder_js || folder_parent+"#{affixe}/js"
  end

  # Retourne le path avec l'extension voulue
  def path_ext extension
    folder_parent + "#{affixe}.#{extension}"
  end
  # Retourne le path alternatif (si le fichier se trouve dans un dossier
  # portant son nom)
  def path_alt_ext extension
    folder_parent + "#{affixe}/#{affixe}.#{extension}"
  end

  # ---------------------------------------------------------------------
  #   États

  def exist?
    @is_exist ||= path.exist?
  end

  # ---------------------------------------------------------------------
  # Propriétés

  def bindee
    @bindee ||= ( site.objet_binded.respond_to?(:bind) ? site.objet_binded : nil )
  end
  def path          ; @path           ||= (folder + relpath)  end
  def affixe        ; @affixe         ||= path.affixe     end
  def path_affixe   ; @path_affixe    ||= folder_parent + affixe end
  def folder_parent ; @folder_parent  ||= path.folder end

end
