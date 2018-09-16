# encoding: UTF-8
class SiteHtml
class Admin
class Console

  # Sort dans la sortie spéciale, i.e. en dessous du champ de
  # console, le contenu de la table +table+ en le formatant
  # correctement pour qu'il puisse s'afficher entièrement
  # +table+ Instance {BdD::Table} de la table
  def show_table table

    (site.folder_objet+'database/lib/module/table_content').require
    code = Database::Table._table_content(table)

    special_output code
    "Cf. le code ci-dessous"
  end

end #/Console
end #/Admin
end #/SiteHtml
