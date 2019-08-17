# encoding: UTF-8
=begin

Class Vue

=end
class Vue

  # Chemin relatif à la vue, depuis le dossier 'objet'
  attr_reader :relpath
  attr_reader :folder

  def initialize relpath, folder = nil, bindee = nil
    folder, relpath = Vue.normalize(folder, relpath)
    @relpath = relpath
    @folder  = folder || site.folder_objet
    @bindee  = bindee
    # Pour pouvoir retrouver rapidement une vue actuellement affichée,
    # on indique son path dans le débug
    # debug "---> vue “#{path}” (@already_required: #{@already_required.inspect})"
  end

  # Retourne le code déserbé de la vue (elle doit exister et on doit
  # avoir testé son existence avant d'appeler cette méthode)
  def output
    require_all unless @already_required
    path.deserb bindee
  end

  def bindee
    @bindee ||= ( site.objet_binded.respond_to?(:bind) ? site.objet_binded : nil )
  end

  def exist?
    @is_exist ||= path.exist?
  end

  def path          ; @path ||= (folder + relpath)  end
  def affixe        ; @affixe ||= path.affixe     end
  def path_affixe   ; @path_affixe ||= folder_parent + affixe end
  def folder_parent ; @folder_parent ||= path.folder end

end
