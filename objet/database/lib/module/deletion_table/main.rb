# encoding: UTF-8
class Database
class << self

  def _remove_table
    req = "DROP TABLE #{param :tblname};"
    site.db_execute(param(:dbname), req, param(:online) == 'on')
    flash "Table #{table_designation} détruite avec succès."
  end

  def _delete_table
    base = param(:dbname)
    table = param(:tblname)
    site.dbm_table(base, table, param(:online) == 'on').delete
    max_id = site.db_execute(base, "SELECT MAX(id) as max_id FROM #{table};")
    max_id = max_id.first[:max_id] || 0 # car +1 ci-dessous
    site.db_execute(base, "ALTER TABLE #{table} AUTO_INCREMENT=#{max_id + 1};")
    flash "Vidage de la table #{table_designation} (dernier ID mis à #{max_id + 1})."
  end
end #/<< self
end #/Database
