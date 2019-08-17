# encoding: UTF-8
class SiteHtml

  # Retourne l'instance SiteHtml::DBM_TABLE de la table MySQL
  def dbm_table db_suffix, table_name, force_online = false
    DBM_TABLE.get(db_suffix.to_sym, table_name, force_online)
  end

  # Pour exécuter une requête sur une base, pas sur une table.
  # Cf. le fichier db_base.rb
  def db_execute db_suffix, request, options = nil
    DBM_BASE.execute(db_suffix, request, options)
  end

  # Pour exécuter une requête sur mysql, en dehors de toute
  # base et de toute table. Par exemple pour obtenir la
  # liste des bases de données.
  #
  #
  def mysql_execute request, online = nil
    request.end_with?(';') || request += ';'
    DBM_TABLE.define_is_offline online
    res = DBM_BASE.client_sans_db.query(request)
    if res.nil?
      true
    else
      res.collect { |row| row }
    end
  rescue Exception => e
    debug e
    return false
  end

class DBM_TABLE # DBM_TABLE pour DataBase Mysql

  # ---------------------------------------------------------------------
  #   Classe
  # ---------------------------------------------------------------------

  extend MethodesBaseMySQL

  class << self

    attr_reader :tables

    # Retourne la table (instance {SiteHtml::DBM_TABLE}) de nom
    # +tablename+ dans la base de db_suffix +db_suffix+ qui peut
    # être :hot, :cold, :cnarration, :unan.
    #
    # Trois valeurs possibles pour +force_online+
    # - NIL   Dans ce cas, on regarde dans ONLINE/OFFLINE où on est
    # - FALSE   On force le traitement en local
    # - TRUE    On force le traitement en distant
    def get db_suffix, tablename, force_online = nil
      define_is_offline force_online
      @tables ||= {}
      @tables["#{db_suffix}.#{tablename}#{force_online ? '' : '.online'}"] ||= begin
        new(db_suffix, tablename, force_online).create_if_needed
      end
    end

    # Ajoute une table à la liste des tables, pour ne pas
    # avoir à les retester tout le temps. Utile si on ne
    # passe pas par `get` pour récupérer une table.
    def add table
      @tables ||= {}
      @tables["#{table.db_suffix}.#{table.name}"] = table
    end

    # (Pour la construction des tables)
    # {SuperFile} Dossier contenant les schémas des
    # tables des bases de données.
    # Elles sont réparties en deux dossier, :hot ou :cold.
    def folder_path_schema_tables db_suffix = nil
      @folder_path_schema_tables ||= site.folder_database + 'definition_tables_mysql'
      db_suffix ? @folder_path_schema_tables + "base_#{db_suffix}" : @folder_path_schema_tables
    end

    # Retourne true si la base de données +dbname+ existe
    #
    # @usage      existe = SiteHtml::DBM_TABLE.database_exist?(db_nom_complet)
    #
    def database_exist? dbname
      client_sans_db.query('SHOW DATABASES;').each do |row|
        return true if row['Database'] == dbname
      end
      return false
    end

    # {Array} Retourne la liste de toutes les bases de données
    #
    def databases
      client_sans_db.query('SHOW DATABASES;').collect do |row|
        row['Database']
      end
    end

  end #/<< self

  # ---------------------------------------------------------------------
  #   Instance d'une table de database
  # ---------------------------------------------------------------------

  # Nom de la table
  attr_reader :name

  # Pour savoir si c'est une table :hot, :cold, :cnarration,
  # etc.
  attr_reader :db_suffix

  attr_reader :db_name

  # Si True, c'est avec les bases online qu'on travaille
  attr_reader :force_online

  # Instanciation de la table, avec son db_suffix (dans :hot
  # ou dans :cold — la base) et son nom +table_name+
  #
  # +force_online+ permet de forcer l'interaction avec
  # la base online (pour la synchronisation par exemple)
  #
  def initialize db_suffix, table_name, force_online = false
    @name           = table_name
    @db_suffix      = db_suffix
    @force_online   = force_online
    # debug "Dans l'instanciation de la table"
    # debug "@name: #{@name.inspect} / @db_suffix: #{@db_suffix.inspect} / @force_online: #{@force_online.inspect}"
    # debug "client_data : #{client_data.inspect}"
  end

  # On met cette méthode qui auparavant renvoyait le suffix de la
  # base et a été remplacé par `db_suffix`. Mais on n'est pas sûr
  # que la méthode `type` ne soit plus utilisée à l'extérieur, donc il
  # faut conserver cette méthode
  def type
    warn 'La méthode `type` ne doit plus être utilisée. Remplacer par `db_suffix`.'
    db_suffix
  end

  # ---------------------------------------------------------------------
  #   PRINCIPALES REQUÊTES
  # ---------------------------------------------------------------------
  # Pour insérer un enregistrement dans la table
  # (quand il n'existe pas).
  #
  def insert params
    Request.new(self, params).insert
  end
  def select params = nil, options = nil
    Request.new(self, params, options).select
  end
  def get who, options = nil
    Request.new(self, who, options).get
  end
  def update who, values
    Request.new(self, who, values).update
  end
  def set who, values
    Request.new(self, who, values).set
  end
  def delete who = nil
    Request.new(self, who).delete
  end
  def count who = nil
    Request.new(self, who).count
  end

  NIL_TIME = Time.at(0)

  # Retourne le timestamp {Fixnum} de la dernière actualisation
  # de la table courante.
  def last_update default_value = NIL_TIME
    ((r = client.query(request_last_update)).nil? ? nil : r.first['UPDATE_TIME']) || default_value
  end


  #
  # / FIN REQUÊTES PRINCIPALES
  # ---------------------------------------------------------------------

  # Redéfinit le prochain ID en prenant le dernier ID en repère
  def reset_next_id
    max_id = site.db_execute(db_suffix, "SELECT MAX(id) as max_id FROM #{name};")
    max_id = (max_id.first[:max_id] || 0) + 1
    site.db_execute(db_suffix, "ALTER TABLE #{name} AUTO_INCREMENT=#{max_id};")
  end

  # Le client ruby qui permet d'intergagir avec la base de
  # données.
  def client
    @client ||= begin
      Mysql2::Client.new(client_data.merge(database: db_name))
    end
  end
  def client_data ; self.class.client_data end

  # Nom de la base de données contenant la table.
  # Soit la base :hot soit la base :cold.
  def db_name
    @db_name ||= "#{self.class.prefix_name}#{db_suffix}"
  end

  # Retourne TRUE si la table existe, FALSE si elle
  # n'existe pas.
  def exists?
    if self.class.tables.key?("#{db_suffix}.#{name}#{force_online ? '.online' : ''}")
      true
    else
      force_query_existence
    end
  end
  alias :exist? :exists?

  def force_query_existence
    begin
      client.query("SELECT 1 FROM #{name} LIMIT 1;")
      true
    rescue Exception => e
      false
    end
  end

  # Code de la requête pour tester la date de la dernière
  # modification de la table.
  def request_last_update
    @request_last_update ||= <<-MYSQL
SELECT UPDATE_TIME
  FROM   information_schema.tables
  WHERE  TABLE_NAME = '#{name}';
     MYSQL
  end


  # ---------------------------------------------------------------------
  #   Méthodes utilitaires
  # ---------------------------------------------------------------------
  # Destruction de la table courante
  # PRUDENCE !
  # Retourne true si la table n'existe plus, false dans le
  # cas contraire.
  def destroy
    client.query("DROP TABLE IF EXISTS #{name}")
    self.class.tables.delete("#{db_suffix}.#{name}")
    exists? == false
  end
  alias :drop :destroy

  # ---------------------------------------------------------------------
  #   Méthodes utiles à la création de la table
  # ---------------------------------------------------------------------

  # Lorsque c'est une table dans :users_tables, le nom
  # est composé de <nom table>_<id user>.
  # Il faut prendre le préfixe pour obtenir le nom de la table
  # pour trouver sa définition et son code de création.
  # Il faut prendre le suffixe, donc l'ID de l'user pour pour
  # envoyer à la création pour composer une table qui s'appellera
  # bien <nom table>_<id user>, donc une table unique pour l'user
  def prefix_name
    @prefix_name || split_name
  end
  def suffix_name # en fait = l'ID de l'user
    @suffix_name || split_name
    @suffix_name
  end
  def split_name
    dname = name.split('_')
    @suffix_name = dname.pop
    @prefix_name = dname.join('_')
  end

  # Chemin d'accès au schéma de la table
  def schema_path
    @schema_path ||= begin
      sp =
        if db_suffix == :users_tables
          self.class.folder_path_schema_tables(db_suffix) + "table_#{prefix_name}.rb"
        else
          self.class.folder_path_schema_tables(db_suffix) + "table_#{name}.rb"
        end
      sp.exist? || raise("Le schéma de la table (#{sp}) est introuvable…")
      sp
    end
  end
  # Le nom du schéma, c'est-à-dire le nom de la méthode
  # qui va renvoyer le code de création de la table.
  def schema_name
    @schema_name ||= begin
      if db_suffix == :users_tables
        "schema_table_#{prefix_name}".to_sym
      else
        "schema_table_#{name}".to_sym
      end
    end
  end

  def code_creation_schema
    @code_creation_schema ||= begin
      schema_path.require
      if db_suffix == :users_tables
        send(schema_name, suffix_name)
      else
        send(schema_name)
      end
    end
  end
  # Crée la table si elle n'existe pas.
  # RETURN toujours l'instance courante, pour le chainage
  def create_if_needed
    create unless exists?
    return self
  end

  def create
    client.query( code_creation_schema )
    unless force_query_existence
      raise("La table #{name} n'a pas été crée, dans #{db_name}…")
    end
  end
  #
  # /fin des méthodes pour la création de la table

end #/MDB
end #/SiteHtml
