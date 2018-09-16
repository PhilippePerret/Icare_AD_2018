# encoding: UTF-8
raise_unless_admin

def table_designation
  @table_designation ||= "#{site.prefix_databases}_#{param :dbname}.#{param :tblname}"
end

case param(:operation)
when 'get_table_list'
  # = AJAX =
  # Retourne la liste des tables de la base de suffixe param(:dbname)
  dbsuffix = param(:dbname).nil_if_empty
  dbsuffix != nil || (raise 'Il faut définir le nom (suffixe) de la base de données.')
  Ajax << {tables: Database.new(dbsuffix).table_names.join(' ')}

when 'show_table_content'
  # = AJAX =
  #
  # Montrer le contenu d'une table ou, si param(:filter) est seulement un
  # nombre, mettre une rangée en édition.
  #
  Database.require_module 'table_content'
  Ajax << {mysql_result: Database::Table._table_content}

when 'save_new_data_row'
  # = AJAX =
  Database.require_module 'save_row'
  Database::Table._save_row

when 'synchronize'
  Database.require_module 'synchronisation'
  resultat = Database::Table._synchronize
  Ajax << {mysql_result: resultat}

when 'compare_online_offline'
  Database.require_module 'comparaison'
  retour =
    begin
      Database._compare_online_offline(param(:dbname), param(:tblname))
    rescue Exception => e
      debug e
      "ERREUR : #{e.message} (voir le détail dans le fichier debug)"
    end
  Ajax << {mysql_result: retour } # pretty_inspect

when 'remove_table'
  # = AJAX =
  Database.require_module 'deletion_table'
  Database._remove_table

when 'empty_table'
  # = AJAX =
  Database.require_module 'deletion_table'
  Database._delete_table

when 'exec_db_request'
  # = AJAX =
  # Exécution de la requête demandée sur la table choisie
  pure_mysql_code = param(:pure_mysql) == 'on' # pour savoir si c'est du pure code MySQL
  code =  "site.dbm_table(:#{param(:dbname)}, '#{param(:tblname)}', #{((param(:online) == '1' || ONLINE)).inspect})"
  code += ".#{param :request}"
  # debug "code : #{code.inspect}"
  begin
    res = eval(code)
  rescue Exception => e
    debug e
    res = "# ERREUR EN EXÉCUTANT LE CODE <code>#{code}</code> : #{e.message}"
  end
  # debug "res : #{res.inspect}"
  retour =
    case res
    when Hash, Array then res.pretty_inspect
    else res
    end
  Ajax << {mysql_result: retour } # pretty_inspect
  flash "Requête exécutée avec succès sur la table #{table_designation}."
end
