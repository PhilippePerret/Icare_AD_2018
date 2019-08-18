# encoding: UTF-8
=begin

  Instance Database
  -----------------
  Une base de données en particulier

=end
class Database
  attr_reader :db_suffix
  def initialize db_suffix
    @db_suffix = db_suffix
  end

  # Le nom complet de la base de données
  def db_name
    @db_name ||= "#{site.prefix_databases}_#{db_suffix}" 
  end
end
