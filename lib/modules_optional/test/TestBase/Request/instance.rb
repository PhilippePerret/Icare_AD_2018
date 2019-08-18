# encoding: UTF-8
=begin

  class SiteHtml::TestSuite::TestBase::Request
  --------------------------------------------
  Gestion des requêtes de bases de données

=end
class SiteHtml
class TestSuite
class TestBase
class Request

  ERROR = {
    more_than_one_result: "Il ne devrait y avoir qu'un résultat dans la table, mais %i ont été trouvés…"
  }

  # Pour garder une trace du premier argument
  # (utile pour les messages d'erreur)
  attr_reader :first_arg

  # Nil ou définit à l'instanciation
  attr_reader :row

  attr_reader :options

  # +row_or_table+ Instance de la rangée ou de la table
  def initialize(row_or_table, options=nil)
    # debug "-> initialize"
    @first_arg = row_or_table
    if row_or_table.instance_of?(SiteHtml::TestSuite::TestBase::TestTable)
      @ttable = row_or_table
    else
      @row = row_or_table
    end
    @options = options || {}
  end

  # ---------------------------------------------------------------------
  #   Requêtes qu'on peut envoyer à la méthode `execute` de cette
  #   instance requête
  # ---------------------------------------------------------------------
  # Construction des requêtes
  #
  def select_request
    # debug "-> select_request (@select_request = #{@select_request.inspect})"
    @select_request ||= select_request_multi_lines.gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ').strip
  end
  def count_request
    @count_request ||= count_request_multi_lines.gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ').strip
  end
  # Requête pour définir les données dans la base de
  # données.
  def set_request hdata
    @set_request ||= set_request_multi_lines(hdata).gsub(/\n/, " ").gsub(/\t/,' ').gsub(/( +)/, ' ').strip
  end

  #
  # ---------------------------------------------------------------------

  # Exécution de la requête, online ou offline
  #
  # Par défaut, +sql_request+ est la requête de SELECT
  #
  def execute( sql_request = nil )
    # debug "-> execute (sql_request: #{sql_request.inspect})"
    sql_request ||= select_request
    send(online? ? :execute_online : :execute_offline, sql_request)
    debug "sql_request : #{sql_request.inspect}"
    debug "@resultats: #{@resultats.inspect}"
    @resultats = @resultats.collect { |h| h.to_sym }
    unless plusieurs_resultats?
      nombre_resultats <= 1 || raise(ERROR[:more_than_one_result] % nombre_resultats)
    end
    return self
  end

  def execute_online sql_request
    # debug "REQUETE SSH : #{request_ssh.inspect}"
    res = `#{request_ssh} 2>&1`
    # debug "res : #{res.inspect}"
    res = Marshal.load(res)
    # debug "res démarshalisé : #{res.inspect}"
    @resultats = []
    if res[:erreur_sql]
      error res[:erreur_sql]
    elsif res[:fatale_erreur]
      error "# ERREUR FATALE #{res[:fatale_erreur]}"
    else
      @resultats = res[:resultats]
    end
  end
  def request_ssh
    "ssh #{site.serveur_ssh} \"ruby -e \\\"#{request_ruby_in_ssh}\\\"\""
  end
  def request_ruby_in_ssh
    <<-SSH
#{procedure_ruby_str sql_request}
result = {
  database:             @db_path,
  erreur_sql:           @erreur_sql,
  erreur_fatale:        @erreur_fatale,
  request_sql:          @sql_request,
  resultats:            @resultats,
  nombre_changements:   @nombre_changements
}
STDOUT.write(Marshal.dump(result))
SSH
  end

  def execute_offline sql_request
    procedure_ruby sql_request
  end

  def resultats
    @resultats || execute
    @resultats
  end
  def first_resultat
    @first_resultat ||= resultats.first
  end

  # Nombre de changements produits dans la table après
  # l'exécution de la requête
  def nombre_changements
    @nombre_changements || execute
    @nombre_changements
  end

  def procedure_ruby sql_request
    # debug "-> procedure_ruby(sql_request=#{sql_request.inspect})"
    code = procedure_ruby_str sql_request
    # debug "CODE: #{code}"
    begin
      eval(procedure_ruby_str sql_request)
    rescue Exception => e
      debug e
      error e.message
    end
    if @erreur_fatale || @erreur_sql
      raise "Une erreur est survenue : ERREUR FATALE: #{@erreur_fatale} / ERREUR SQL: #{@erreur_sql}" +
      "\nREQUETE FAUTIVE : #{sql_request.inspect}"
    end
    # debug "<-- procedure_ruby_str"
    @erreur_fatale && raise( @erreur_fatale )
  end

  # La Test-Table courante, qu'on prend soit dans la
  # rangée transmise à l'instanciation (`row`) soit dans la
  # table transmise à l'instanciation
  def ttable
    @ttable ||= begin
      if @row.nil?
        raise "`@row` est nil dans l'instance #{self.class} instancié avec #{first_arg.class}::#{first_arg}. Impossible de définir `ttable`."
      else
        @row.ttable
      end
    end
  end
  def racine
    @racine ||= (online? ? '/home/boite-a-outils/www' : '.')
  end
  def db_path
    @db_path || "#{racine}#{ttable.database.path.to_s[1..-1]}"
  end

  def procedure_ruby_str sql_request
    raise 'Il ne faut plus utiliser sqlite3'
    <<-PROC
if #{SiteHtml::TestSuite::online?.inspect}
  $: << '/home/boite-a-outils/.gems/gems/sqlite3-1.3.10/lib'
  require 'sqlite3'
end
begin
  @erreur_fatale      = nil
  @resultats          = nil
  @nombre_changements = nil
  @db   = nil
  @pst  = nil
  @db_path = %Q{#{db_path}}
  File.exist?(@db_path) || (raise %Q{La base de données '#{db_path}' est introuvable} )
  @sql_request = %Q{#{sql_request}}
  @db   = S Q L i t e 3::Database.open( @db_path )

  # # Pour Voir ce qu'il y a dans la table
  # table_name = 'users'
  # pst = @db.prepare("SELECT * FROM \#{table_name};")
  # res = pst.execute
  # res.each_hash do |h|
  #   debug "RES: \#{h.inspect}"
  # end

  @pst  = @db.prepare( @sql_request )
  res   = @pst.execute
  @nombre_changements = @db.changes
  @resultats = Array::new
  res.each_hash { |h| @resultats << h }
rescue S Q L ite3::Exception => e
  @erreur_sql = e
rescue Exception => e
  @erreur_fatale = e
ensure
  @pst.close if @pst
  @db.close  if @db
end
PROC
  end

  def plusieurs_resultats?
    @plusieurs_resultats === nil && ( @plusieurs_resultats = options[:several] )
    @plusieurs_resultats
  end

  def nombre_resultats
    @nombre_resultats ||= resultats.count
  end

  # Raccourci pour avoir les spécifications de la
  # rangée à travailler, si une rangée est définie
  def specs
    @specs ||= begin
      row.nil? ? nil : row.specs
    end
  end

  def select_request_multi_lines
    @select_request_multi_lines ||= begin
      options ||= Hash.new
      what  = options[:what] || "*"
      order = options[:order]
      order = " ORDER #{order}" unless order.nil?
      limit = options[:limit]
      limit = " LIMIT #{limit}" unless limit.nil?
      <<-SQL
SELECT #{what}
FROM #{ttable.name}
#{where_clause_finale}#{order}#{limit};
      SQL
    end
  end

  # Requête pour compte un nombre de choses
  def count_request_multi_lines
    @count_request_multi_lines ||= begin
      where_clause_final = where_clause
      <<-SQL
SELECT COUNT(*)
FROM #{ttable.name}
#{where_clause_finale};
      SQL
    end
  end

  # Requête pour définir des valeurs dans une rangée
  # +hdata+ Les données à définir dans la rangée spécifié
  # par le possesseur de la requête (qui doit être une Row)
  def set_request_multi_lines hdata
    values_set =
      hdata.collect do |col, val|
        "#{col} = #{realvalue2sqlvalue val}"
      end.join(', ')
    <<-SQL
UPDATE #{ttable.name}
SET #{values_set}
#{where_clause_finale};
    SQL
  end

  def where_clause_finale
    @where_clause_finale ||= begin
      if where_clause.nil?
        ""
      else
        "WHERE #{where_clause}"
      end
    end
  end
  # Construction de la clause WHERE en fonction des
  # spécifications de la requête
  def where_clause
    @where_clause ||= begin
      case specs
      when NilClass
        nil
      when Integer
        "id = #{specs}"
      else
        specs.collect do |k,v|
          v = realvalue2sqlvalue v
          "( #{k} = #{v} )"
        end.join(' AND ')
      end
    end
  end

  def online?
    @is_online ||= SiteHtml::TestSuite::online?
  end

  # Reçoit une valeur quelconque et renvoie la valeur
  # à mettre dans le requête SQL en sachant qu'elle pourra
  # être envoyée par SSH et qu'il ne faut donc pas utiliser
  # de guillemets doubles.
  def realvalue2sqlvalue val
    case val
    when String then "'#{val.gsub(/'/, "\\'")}'"
    when Array, Hash then val.inspect # STRING => PROBLÈME
    else val
    end
  end

end #/Request
end #/TestBase
end #/TestSuite
end #/SiteHtml
