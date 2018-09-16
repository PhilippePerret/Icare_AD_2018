# encoding: UTF-8
class SiteHtml

  # Exécute la requête +request+ sur la base de suffixe +sufbase+
  # NOTES
  #   * Le nom 'dbm_base' est choisi pour être cohérent avec `dbm_table`
  def dbm_base_execute sufbase, request
    DBM_BASE.execute(sufbase, request)
  end

class DBM_BASE

  extend MethodesBaseMySQL

  class << self

    attr_reader :options
    attr_reader :request
    attr_reader :prepared_values

    # = main =
    #
    # Exécute la requête +request+ sur le base de suffixe +db_suffix+
    #
    # +db_suffix+   Suffixe ajouté à `<prefix base>_` pour obtenir
    #               le nom de la base de données. Le préfixe base peut être
    #               'icare' ou 'boite-a-outils' par exemple.
    # +request+     La requête SQL, un code qui doit être valide
    # +options+     {Hash} d'options. Peut définir :
    #     :online       True => exécute la requête sur la base distante
    #                   False => exécute sur la base locale
    #                   Nil => local ou distant selon l'endroit d'où est
    #                   lancée la requête.
    #     :values       Pour des valeurs "préparées", si la requête
    #                   contient des '?'
    #     :symbolize_names
    #                   Pour retourner des hash symbolisés (true par défaut)
    def execute db_suffix, request, opts = nil
      @options          = opts || Hash.new
      @options.key?(:symbolize_names) || @options[:symbolize_names] = true
      define_is_offline @options[:online]
      @suffix_name      = db_suffix
      @prepared_values  = @options[:values].nil_if_empty
      @request          = request
      @request.end_with?(';') || @request += ';'
      exec
    end

    # Méthode appelée par la méthode suffix_name du module
    # MethodesBaseMySQL lorsque @@suffix_name n'est pas défini. Il faut
    # lui renvoyer la valeur de @suffix_name (un seul arobase).
    def _suffix_name ; @suffix_name end

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
      # Si on passe ici c'est que la requête a pu être exécutée.
      # Note : resultat est nil pour certaines requêtes
      if resultat_brut.nil?
        nil
      else
        if @options[:symbolize_names]
          resultat_brut.collect{|row| row.to_sym }
        else
          resultat_brut.to_a
        end
      end
    end

    def resultat_brut
      begin
        if prepared_values.nil?
          # Exécution "directe" de la requête
          client.query( @request )
        else
          # Exécution "préparée" de la requête
          prepared_statement.execute( *prepared_values )
        end
      rescue Exception => e
        debug e
        raise e
      end
    end

    def prepared_statement
      client.prepare( @request )
    end

  end #/<< self
end #/DBM_BASE
end #/SiteHtml
