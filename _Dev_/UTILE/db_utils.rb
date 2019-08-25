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
      res = prepared_statement(request).execute(*values, {symbolize_keys: true})
      res.collect{|r|r}
    end
  end
  # Pour forcer l'exécution de la requête, lorsque l'on est
  # en mode simulation.
  def force_execute request, values = nil
    res = prepared_statement(request).execute(*values, {symbolize_keys: true})
    res.collect{|r|r}
  end
  def prepared_statement(request)
    client.prepare(request)
  end

  # Récupère un résultat dans la table +table+
  # Si +foo+ est un integer, on le prend comme identifiant, sinon, si c'est
  # c'est un Hash, on le prend comme liste de valeurs filtre.
  def get table, foo
    case foo
    when Integer
      condis = ['id = ?']
      values = [foo]
    when Hash
      condis = []
      values = []
      if foo.key?(:after)
        condis << "created_at > ?"
        values << foo.delete(:after)
      end
      if foo.key?(:before)
        condis << "created_at < ?"
        values << foo.delete(:before)
      end
      foo.each do |k, v|
        condis << "#{k} = ?"
        values << v
      end
    else
      raise "Impossible d'obtenir une rangée dans la base de données à l'aide d'autre chose qu'un entier (définissant l'identifiant) ou une table de données (Hash)."
    end
    force_execute("SELECT * FROM #{table} WHERE #{condis.join(' AND ')}", values)
  end
  # Comme précédente mais ne renvoie que le premier résultat (ou le seul)
  def getOne(table, foo)
    get(table,foo).first
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
