# encoding: UTF-8
=begin

Class Vue
---------
Méthodes d'instance

=end
class Vue

  # Méthode qui requiert tout ce qui concerne la vue ou le
  # partiel
  def require_all
    return if @already_required == true
    require_ruby
    require_css
    require_javascript
    @already_required = true
  end

  def require_ruby
    path_ruby.require if path_ruby.exist?
  end
  def require_css
    page.add_css([path_css.to_s]) if path_css.exist?
  end
  def require_javascript
    page.add_javascript([path_js.to_s]) if path_js.exist?
  end

  def path_ruby ; @path_ruby  ||= path_ext('rb')  end
  def path_css  ; @path_css   ||= path_ext('css') end
  def path_js   ; @path_js    ||= path_ext('js')  end

  # Retourne le path avec l'extension voulue
  def path_ext extension
    folder_parent + "#{affixe}.#{extension}"
  end
end
