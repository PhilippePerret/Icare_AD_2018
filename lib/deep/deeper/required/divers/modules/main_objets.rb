# encoding: UTF-8
#
# @usage
#   extend MethodesMainObjet
#
# La classe appelante doit IMPÉRATIVEMENT :
#   * définir `folder`, le dossier de l'objet dans './objet'
#     => {SuperFile}
#     sauf si la classe minorisée a le même nom que le dossier
#     p.e. class Cnarration => dossier './objet/cnarration/'
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

  # Dans l'objet, définir `titre` (def titre; "<valeur>" end)
  # +options+
  #   :onglets_top    Si true, les onglets sont mis au-dessus du sous-
  #                   titre plutôt que tout en bas
  def titre_h1 sous_titre = nil, options = nil
    options ||= Hash.new
    page.title = titre
    datah1 = Hash.new
    page.collection? && datah1.merge!(itemprop: 'name')
    t = titre.in_h1(itemprop: 'name')
    t << onglets if options[:onglets_top]
    t << sous_titre.in_h2 unless sous_titre.nil?
    t << onglets unless options[:onglets_top]
    t
  end

  # Dans l'objet, définir la méthode `data_onglets` retournant
  # les données des onglets en fonction du context
  def onglets
    (data_onglets.empty? || data_onglets.nil?) && (return '')
    data_onglets.collect do |ong_titre, ong_route|
      css = site.current_route?(ong_route) ? 'active' : nil
      ong_titre.in_a(href:ong_route).in_li(class:css)
    end.join.in_ul(class:'onglets')
  end


  # Permet de requérir :
  #   * Si c'est un dossier : tout ce que contient le dossier
  #     du dossier des modules qui doit se trouver dans le dossier
  #     lib/module de l'objet. Par exemple, si l'objet est "analyse",
  #     le module à requérir doit se trouver dans :
  #       ./objet/<objet courant>/lib/module/-ici-
  #   * Si c'est un fichier : le fichier lui-même, qui doit se
  #     trouver dans ./objet/<objet courrant>/lib/module/
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
