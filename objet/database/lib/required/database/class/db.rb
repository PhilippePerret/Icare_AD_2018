# encoding: UTF-8
class Database
class << self

  # Liste des suffixes des bases de données
  # (par exemple, si icare_hot est une base, la liste contiendra 'hot')
  def list
    @list ||= begin
      site.mysql_execute('SHOW DATABASES;').collect do |row|
        dbname = row['Database']
        dbname.start_with?(site.prefix_databases) || next
        dbname.sub(/^#{site.prefix_databases}_/,'')
      end.compact
    end
  end

end #/<< self
end #/Database
