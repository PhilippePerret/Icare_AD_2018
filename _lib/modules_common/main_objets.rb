# encoding: UTF-8
#
# @usage
#   extend MethodesMainObjet
#
# La classe appelante doit IMPÉRATIVEMENT :
#   * définir `folder`, le dossier de l'objet dans './_objet'
#     => {SuperFile}
#     sauf si la classe minorisée a le même nom que le dossier
#     p.e. class Cnarration => dossier './_objet/cnarration/'
#
module MethodesMainObjet

  # Nom de l'objet
  # P.e., pour la classe IcModule::IcEtape::IcDocument, retourne 'ic_document'
  def objet_name
    @objet_name ||= "#{name.to_s.split('::').last.to_s.decamelize}"
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'helper
  # ---------------------------------------------------------------------


  # Retourne un titre et un sous-titre formatés, ainsi que des onglets
  # si la page en possède.
  def titre_h1 sous_titre = nil, options = nil
    page.title = titre
    div = titre.in_h1
    h2 = ''
    h2 << onglets.in_div(id:'navBarSection') if data_onglets?
    h2 << sous_titre if sous_titre
    div << h2.in_h2 if h2 != ''
    return div
  end

  # Return true si des onglets sont définis
  def data_onglets?
    !(data_onglets.empty? || data_onglets.nil?)
  end

  # Onglet dans la version responsive, avec un nav bar
  # Dans l'objet, définir la méthode `data_onglets` retournant
  # les données des onglets en fonction du context
  def onglets
    "Se rendre à…".in_div(class: 'handler')+
    data_onglets.collect do |ong_titre, ong_route|
      css_active = site.current_route?(ong_route) ? ' active' : ''
      ong_titre.in_a(href:ong_route, class: "nav-item nav-link#{css_active}")
    end.join.in_div(class:'content')
  end


  # Permet de requérir :
  #   * Si c'est un dossier : tout ce que contient le dossier
  #     du dossier des modules qui doit se trouver dans le dossier
  #     lib/module de l'objet. Par exemple, si l'objet est "analyse",
  #     le module à requérir doit se trouver dans :
  #       ./_objet/<objet courant>/lib/module/-ici-
  #   * Si c'est un fichier : le fichier lui-même, qui doit se
  #     trouver dans ./_objet/<objet courrant>/lib/module/
  #     Dans ce cas, +module_name+ peut être soit le path relatif
  #     avec ou sans extension.
  def require_module module_name
    ptest = (folder_modules + module_name)
    if ptest.exist? && ptest.folder?
      site.require_all_in ptest
    else
      # Un simple fichier module
      ptest = (folder_modules + "#{module_name}.rb") unless ptest.exist?
      ptest.require
    end
  end

  # Le dossier contenant les modules
  def folder_modules
    @folder_modules ||= (folder_lib + 'module')
  end
  alias :folder_module :folder_modules

  def folder_lib
    @folder_lib ||= (folder + 'lib')
  end

  def folder
    @folder ||= site.folder_objet + objet_name
  end

end
