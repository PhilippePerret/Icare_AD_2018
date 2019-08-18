# encoding: UTF-8
class Database

  # Retourne la liste des noms de table de la base
  def table_names
    @table_names ||= begin
      site.db_execute(db_suffix, 'SHOW TABLES;').collect do |row|
        row.values.first
      end.compact
    end
  end


end
