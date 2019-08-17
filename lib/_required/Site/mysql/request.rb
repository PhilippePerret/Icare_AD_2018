# encoding: UTF-8
=begin

  Instances SiteHtml::DBM_TABLE::Request
  --------------------------------
  Pour le traitement d'une requête dans la table choisie de
  la base choisie.

=end
class SiteHtml
class DBM_TABLE
class Request

  # Instance SiteHtml::DBM_TABLE de la table de la requête
  attr_reader :dbm_table

  # Paramètres définis pour la requête
  attr_reader :params
  # Options définis pour la requête (if any)
  attr_reader :options


  # Nombre de rangées insérées avec INSERT
  attr_reader :nombre_inserted_rows

  # Construit ici
  # -------------
  # La requête telle qu'elle sera envoyée. Ça peut être
  # une requête "simple" ou une requête "préparée"
  attr_reader :request

  # {Array} Liste des valeurs préparées
  attr_reader :prepared_values

  def initialize itable, params, options = nil
    @dbm_table  = itable
    @params     = params  || {}
    @options    = options || {}
    if @options.instance_of?(Array)
      raise "@options ne devrait pas être un array #{@options.inspect}"
    end
    if @params.instance_of?(Hash) && @params.key?(:values)
      @prepared_values = params.delete(:values)
    end
  end

  # ---------------------------------------------------------------------
  #   REQUÊTES PRINCIPALES
  # ---------------------------------------------------------------------

  # INSERTION
  #
  # @USAGE    <table>.insert(<hash de valeurs>)
  #
  # @RETURN L'insertion retourne toujours l'ID de la rangée créée.
  #
  # Pour obtenir le nombre de nouvelles rangées, il faut utiliser
  # <dbm_table>.nombre_inserted_rows et non pas <dbm_table>.row_count
  # car la dernière requête sert à obtenir 'last_insert_id'
  #
  def insert
    @prepared_values ||= []
    @request = request_insert
    resultat = exec
    @nombre_inserted_rows = row_count
    return last_insert_id
  end

  # SELECT
  # ------
  #
  # @USAGE <dbm_table>.select(where, options)
  #
  # @RETURN Un hash des éléments trouvés
  #
  def select
    @prepared_values ||= []
    @request = request_select
    resultat = exec
    return resultat
  end

  # GET
  # ---
  #
  # @usage    <dbm_table>.get( <where>, <options>)
  #
  # Retourne seulement la rangée voulue et seulement une.
  # S'il y en a plusieurs, on ne signale rien.
  # Retourne NIL si aucun élément n'a été trouvé.
  def get
    params_contains_id_or_raise
    resultat = select
    resultat.first
  end

  # UPDATE
  # ------
  #
  # @usage : <dbm_table>.update(<row ref>, <{new data}>)
  #
  # RETURN : True si tout s'est bien passé, false dans le cas
  # contraire.
  def update
    params_contains_id_or_raise
    @prepared_values = []
    @request = request_update
    resultat = exec
    if resultat.nil?
      return 0
    else
      return resultat.count == 1
    end
  end

  # SET
  # ---
  #
  # @usage : <dbm_table>.set(<row ref>, <values>)
  #
  # Permet de choisir entre UPDATE ou INSERT en fonction du
  # fait que la rangée existe ou non.
  #
  def set
    @prepared_values = []
    if rows_exist?
      update
    else
      @params = params.merge(options)
      @params.delete(:where)
      insert
    end
  end

  def delete
    @request = request_delete
    resultat = exec
    # TODO Comment savoir si l'élément a bien été effacé ?
  end

  def count
    @request = request_count
    nombre_rows = 0
    resultat = exec
    unless resultat.nil?
      resultat.each do |row|
        nombre_rows = row.first[1]
      end
    end
    nombre_rows
  end

  # ---------------------------------------------------------------------
  #   REQUÊTES STRING
  # ---------------------------------------------------------------------

  def request_count
    <<-SQL
SELECT COUNT(*) FROM #{dbm_table.name}
  #{where_clause}
  #{group_by_clause}
    SQL
  end

  # Construction de la requête string pour INSERT
  def request_insert
    inserted_columns = params.keys.join(', ')
    @prepared_values = params.values
    inserted_values  = Array.new(params.count, '?').join(', ')
    <<-SQL
INSERT INTO #{dbm_table.name}
  (#{inserted_columns})
  VALUES ( #{inserted_values} )
    SQL
  end

  # Construction de la requête string pour SELECT
  def request_select
    <<-SQL
SELECT #{columns_clause} FROM #{dbm_table.name}
  #{where_clause}
  #{group_by_clause}
  #{order_by_clause}
  #{limit_clause}
  #{offset_clause}
    SQL
  end

  # Construction de la requête string pour UPDATE
  #
  # Note : C'est la valeurs `options` qui contient
  # les valeurs.
  def request_update
    @prepared_values ||= []
    set_clause =
      'SET ' + options.collect do |k, v|
        @prepared_values << v
        "#{k} = ?"
      end.join(', ')

    <<-SQL
UPDATE #{dbm_table.name}
  #{set_clause}
  #{where_clause}
  #{order_by_clause}
  #{limit_clause}
    SQL
  end

  def request_delete
    @prepared_values ||= []
    <<-SQL
DELETE FROM #{dbm_table.name}
  #{where_clause}
  #{order_by_clause}
  #{limit_clause}
    SQL
  end

  # ---------------------------------------------------------------------
  #   Méthodes de fabrication des clauses
  # ---------------------------------------------------------------------

  # +params+ peut être un hash ou un nombre, un string
  # La clause WHERE peut être définie de ces manières
  # suivantes dans params :
  #     - String simple     p.e. 'id = 12'
  #     - String complexe   p.e.  'id = ?'
  #     - Hash              p.e. {id : 12}
  def where_clause
    case params
    when NilClass then return ''
    when Hash
      # formule normale, rien à faire
      if params.key?(:where)
        # OK
      elsif params.key?(:id)
        @params.merge!(where: { id: params.delete(:id) } )
      end
    when Fixnum # un nombre donné comme premier argument
      @params = { where: { id: params } }
    when String # un string donné comme premier argument => condition
      @params = { where: params }
    end

    # On peut prend where dans les paramètres
    where = params[:where]
    case where
    when NilClass then ''
    when String then 'WHERE ' + where
    when Hash then
      # Pour un Hash, on transforme en "key = :key" et on incrémente
      # les valeurs qui devront être bindées
      @prepared_values ||= []
      @prepared_values += where.values
      'WHERE ' + where.collect{|k, v| "#{k} = ?"}.join(' AND ')
    else
      raise 'La clause WHERE doit être définie par un NIL, un String ou un Hash.'
    end
  end
  def columns_clause
    begin
      cols = params[:columns] || params[:colonnes] if params.instance_of?(Hash)
      cols ||= options[:colonnes] || options[:columns] if options.instance_of?(Hash)
    rescue Exception => e
      debug "# ERREUR columns_clause : #{e.message}"
      debug "# ERREUR columns_clause, options = #{options.inspect}"
      debug "# ERREUR columns_clause, params = #{params.inspect}"
      error "Erreur dans columns_clause de la requête MYSQL (voir débug). Je retroune '*'" if OFFLINE
      return '*'
    end
    case cols
    when NilClass then '*'
    when Array    then (cols << :id).uniq.join(', ')
    when String   then cols
    else
      raise 'Le paramètre :colonnes doit être NIL, un Array ou un String.'
    end
  end

  def limit_clause
    if params.key?(:limit)
      "LIMIT #{params[:limit]}"
    else
      ''
    end
  end
  def group_by_clause
    if params.key?(:group) || params.key?(:group_by)
      "GROUP BY #{params[:group] || params[:group_by]}"
    else
      ''
    end
  end
  def order_by_clause
    if params.key?(:order) || params.key?(:order_by)
      "ORDER BY #{params[:order] || params[:order_by]}"
    else
      ''
    end
  end

  def offset_clause
    offset = params[:offset] || params[:from]
    case offset
    when NilClass then ''
    when Fixnum   then "OFFSET #{offset}"
    else
      raise 'La classe OFFSET doit être un nombre (Fixnum)'
    end
  end

  # / Fin de méthodes de fabrication des clauses
  # ---------------------------------------------------------------------

  # Retourne true si les rangées définies par la clause
  # where existent. En général, ça ne test qu'une seule
  # rangée pour la méthode SET.
  def rows_exist?
    @prepared_values = []
    @request = "SELECT COUNT(*) FROM #{dbm_table.name} #{where_clause} LIMIT 1"
    resultat = exec
    unless resultat.nil?
      resultat.first.values.first > 0
    else
      return false
    end
  end


  # Renvoie le nombre de rangées touchées par la dernière
  # requête (en tout cas avec INSERT, pas encore vérifié avec
  # les autres)
  #
  # On peut l'obtenir dans le programme à l'aide de :
  #   <dbm_table>.row_count
  #
  def row_count
    nb = nil
    dbm_table.client.query('SELECT ROW_COUNT()').each do |row|
      nb = row.values.first
    end
    return nb
  end

  # Provoque une erreur si +params+, c'est-à-dire le
  # deuxième argument transmis à l'instanciation ne définit pas
  # de référence à une rangée par :
  #   - Fixnum                L'ID de la rangée
  #   - {id: Fixnum}          Définition par hash
  #   - {where: 'condition'}  La clause where définie dans le hash
  #
  def params_contains_id_or_raise
    return true if params.instance_of?(Fixnum)
    if params.instance_of?(Hash) && (params.key?(:where) || params.key?(:id))
      true
    else
      raise 'Le premier argument doit définir l’ID de la rangée (attendu : un fixnum ou un hash définissant :where ou :id).'
    end
  end


  # Retourne l'ID de la dernière ligne insérée
  #
  # Attention/Rappel : Si plusieurs lignes sont insérées en une
  # seule fois, seule l'ID de la PREMIÈRE ligne est retournée.
  def last_insert_id
    lii = nil
    dbm_table.client.query('SELECT LAST_INSERT_ID()').each do |row|
      lii = row.values.first
    end
    lii
  end

  # = main =
  #
  # Exécution de la requête.
  # RETURN Le résultat obtenu.
  #
  # Deux façons d'exécuter la requête : soit de façon directe
  # par `query`, soit en préparant la requête.
  # Ce qui détermine la manière, c'est la définition ou non de la
  # propriété @prepared_values.
  def exec
    resultat =
      begin
        if prepared_values.nil? || prepared_values.empty?
          dbm_table.client.query( final_request )
        else
          prepared_statement.execute( *prepared_values )
        end
      rescue Exception => e
        debug "# ERREUR MYSQL : #{e.message}" rescue nil
        debug "# REQUEST : #{final_request}" rescue nil
        debug "# VALEURS PRÉPARÉES : #{prepared_values.inspect}" rescue nil
        debug e.backtrace.join("\n") rescue nil
        raise e
      end
    # Si on passe ici c'est que la requête a pu être exécutée.
    # Mais resultat est nil pour certaines requêtes
    unless resultat.nil?
      resultat = resultat.collect { |row| row.to_sym }
    end
    return resultat
  end

  def prepared_statement
    dbm_table.client.prepare(final_request)
  end

  # Requête définitive
  #
  # Noter qu'il ne faut pas la mettre dans une variable
  # d'instance car plusieurs sortes de requête peuvent être
  # appelée au cours de la même instance (par exemple pour
  # `set` quand il faut voir si la rangée existe ou non)
  def final_request
    r = request.gsub(/\n/, ' ').gsub(/ +/, ' ').strip + ';'
    # debug "@REQUEST: #{r}"
    # debug "@PREPARED_VALUES: #{@prepared_values.inspect}"
    r
  end

end #/Request
end #/DBM_TABLE
end #/SiteHtml
