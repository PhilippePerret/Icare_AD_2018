# encoding: UTF-8
=begin
Extension des instances User pour la gestion des variables dans
la table `variables` de la base de données personnelles.
C'est notamment cette table qui mémorise les préférences de chaque
user.
=end
class User

  # Toutes les variables (valeurs de la table `variables` qui
  # fonctionne en name: <valeur>)
  def variables
    @variables ||= begin
      h = Hash.new
      table_variables.select.each do |d|
        h.merge! d[:name].to_sym => var_value_to_real(d)
      end
      # debug "variables : #{h.inspect}"
      h
    end
  end


  # Mets la variable +var_name+ à +var_value+ dans la table `variables`
  # de l'user.
  # Note : Pour l'enregistrement de plusieurs variables en même temps,
  # utiliser la méthode `set_vars` ci-dessous.
  def set_var var_name, var_value = nil
    # Enregistrement de plusieurs variables d'un coup
    if var_name.instance_of?(Hash)
      if var_name.count > 1
        set_vars(var_name)
        return
      else
        var_value = var_name.values.first
        var_name  = var_name.keys.first
      end
    end

    # NAME doit toujours être un string (même lorsqu'il est
    # fourni en Symbol)
    var_name = var_name.to_s

    # Le Hash qui sera enregistré dans la table
    h2save = var_real_to_hash2save( var_value )

    # Création ou update de la variable
    if table_variables.count(where:{name: var_name}) == 0
      h2save.merge!(name: var_name)
      table_variables.insert(h2save)
    else
      table_variables.set( {where:{name: var_name}}, h2save )
    end
  end

  # Return l'index 0-start du type de la valeur
  # +var_value+
  def var_to_save_type var_value
    case var_value
    when TrueClass, FalseClass then 7
    else VARIABLES_TYPES.index(var_value.class)
    end
  end

  # Prend la valeur réelle et retourne la valeur qu'il va falloir
  # enregistrer dans la colonne `value` de la table `variable`
  def var_real_to_saved var_value
    case var_value
    when TrueClass  then "1"
    when FalseClass then "0"
    when NilClass   then nil
    when Hash, Array  then var_value.to_json
    when Fixnum, Bignum, Float then var_value.to_s
    else var_value.to_s
    end
  end

  # Prend la valeur à sauver comme argument et
  # retourne un {Hash} définissant :value, la valeur réelle à
  # enregistrer dans la table et :type, le type de la valeur,
  # nombre de 0 à x (cf. VARIABLES_TYPES)
  def var_real_to_hash2save var_value
    {
      value: var_real_to_saved( var_value ).freeze,
      type:  var_to_save_type(var_value).freeze
    }
  end


  # ---------------------------------------------------------------------
  #   Méthodes utiles à `set_vars`

  # {Hash} Return un hash de toutes les variables dont les noms
  # sont contenues dans le {Array} +arr_var_names+
  # NOTE IMPORTANTE : Les données (valeur de la clé) sont brutes,
  # sauf si +as_real_values+ est true (false par défaut, pour accélérer
  # la méthode, qui est surtout appelée pour `set_vars`)
  def get_vars arr_var_names, as_real_values = false
    hsaved = Hash.new
    arr_names = arr_var_names.collect{|n| "'#{n}'"}
    where = "name IN (#{arr_names.join(', ')})"
    saved_vars = table_variables.select(where: where).each do |hvalue|
      # hvalue => {:id, :name, :value, :type}
      hsaved.merge!(hvalue[:name] => hvalue)
    end
    # Remplacer les valeurs brutes par les vraies valeurs si demandé
    hsaved.each { |k, hk| hsaved[k] = var_value_to_real(hk) } if as_real_values
    return hsaved
  end

  # ---------------------------------------------------------------------

  # Sauve dans la table `variables` en enregistrant les données
  # les unes après les autres. Des essais ont été faits pour
  # distinguer les UPDATE des INSERT mais ça foirait, donc je
  # suis revenu à ça, même si c'est plus long. Noter que ça ne
  # posera jamais trop de problèmes puisqu'on a affaire à une
  # table qui ne concerne que l'user courant.
  def set_vars hdata
    hdata.each do |var_name, var_value|
      set_var(var_name, var_value)
    end
  end

  # Récupérer la valeur de la variable `var_name` (qui peut avoir
  # n'importe quel type, String ou Symbol, mais sera toujours
  # recherché en String dans la table)
  # +default_value+ est la valeur par défaut qui sera retournée
  # si la valeur est nil. Noter que pour une valeur booléenne
  # false, il ne faut pas remplacer par la valeur par défaut,
  # sinon ça serait fait chaque fois qu'elle est fausse
  def get_var var_name, default_value = nil
    h = table_variables.get(where:{name: var_name.to_s})
    return default_value if h.nil?
    real_value = var_value_to_real( h )
    return real_value if h[:type] == 7
    real_value || default_value
  end

  # Prend la donnée définie par +h+ (contenant une valeur
  # string et un type par nombre) et retourne la valeur dans
  # son bon type, par exemple un nombre, ou un Hash, etc.
  # Sert à la table `variables` qui enregistre n'importe quel
  # type de donnée scalaire et la restitue telle quelle.
  def var_value_to_real h
    # Cf. VARIABLES_TYPES pour connaitre l'ordre (index)
    # debug "[var_value_to_real] h = #{h.inspect}::#{h.class}"
    case h[:type]
    when 0      then h[:value].to_s # String
    when 1, 2   then h[:value].to_i
    when 3      then h[:value].to_f
    when 4, 5   then
      if h[:value].instance_of? String
        JSON.parse(h[:value])
      else
        h[:value] # car les méthode BdD le transforme déjà
      end
    when 6      then nil
    when 7      then (h[:value] == "1")
    end
  end


end
