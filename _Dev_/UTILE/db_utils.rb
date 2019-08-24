# encoding: UTF-8
=begin

  Utilitaire pour travailler sur la base de donnée

  @usage :

      require_relative 'db_utils'
      SIMULATION = true # mettre false pour corriger vraiment la base
      ON_OR_OFF = :offline # mettre :online pour la table online

      # Les données mysql doivent être définies dans ./data/secret/mysql.rb

      Utiliser `DB.execute(request, values)` pour une requête simulée ou réelle
      Utiliser `DB.force_execute(request, value)` pour exécuter vraiment une
      requête dans le cas d'une simulation (souvent pour obtenir les valeurs
      de base)

=end
require 'mysql2'

class DB
class << self
  def execute request, values = nil
    if SIMULATION
      puts "\n\nRequête simulée: #{request}"
      puts "VALUES: #{values.inspect}"
    else
      prepared_statement(request).execute(*values, {symbolize_keys: true})
    end
  end
  # Pour forcer l'exécution de la requête, lorsque l'on est
  # en mode simulation.
  def force_execute request, values = nil
    prepared_statement(request).execute(*values, {symbolize_keys: true})
  end
  def prepared_statement(request)
    client.prepare(request)
  end
  def client
    @client ||= Mysql2::Client.new(client_data)
  end
  def client_data
    @client_data ||= begin
      require './data/secret/mysql'
      DATA_MYSQL[ON_OR_OFF]
    end
  end
end #<< self
end #/SQL
