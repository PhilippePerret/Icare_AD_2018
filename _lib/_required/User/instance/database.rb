# encoding: UTF-8
=begin

Extensions User instance pour les bases de données

=end
class User

  # Table COMMUNE de tous les users
  def table_users
    @table_users ||= self.class::table_users
  end
  alias :table :table_users

  # Table PERSONNELLE contenant les variables
  # Noter que c'est une méthode d'instance
  # Cf. le fichier `inst_variables.rb`
  def table_variables
    # @table_variables ||= create_table_unless_exists('variables')
    @table_variables ||= site.dbm_table(:users_tables, "variables_#{id}")
  end

end #/User
