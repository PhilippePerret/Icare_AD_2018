# encoding: UTF-8
=begin

Extension des instances User pour les préférences

=end
class User

  # Enregistre la préférence +pref_id+ à la valeur +pref_value+
  # +pref_id+ NE DOIT PAS être préfixé avec "pref_"
  # Cf. User > Preferences.md
  def set_preference pref_id, pref_value = nil
    if pref_id.instance_of?(Hash)
      pref_value = pref_id.values.first
      pref_id    = pref_id.keys.first
    end
    pref_id = pref_id.to_sym
    var_key = "pref_#{pref_id}".to_sym.freeze
    set_var( var_key, pref_value )
    @preferences[pref_id] = pref_value
  end

  # Enregistre un flot de préférences d'un bloc
  # WARNING : Les +pref_id+ NE DOIVENT PAS être préfixés avec "pref_"
  def set_preferences hpreferences
    # Modifier les clés pour l'enregistrement dans la table `variables`
    hprefs_def = Hash.new
    hpreferences.each { |k, v| hprefs_def.merge!("pref_#{k}" => v) }
    set_vars hprefs_def
    @preferences.merge!(hpreferences.to_sym)
  end

  # Retourne la valeur de la préférence d'identifiant +pref_id+
  # Cf. User > Preferences.md
  def preference pref_id, default_value = nil
    pref_id = pref_id.to_sym
    @preferences[pref_id] ||= begin
      get_var("pref_#{pref_id}", default_value)
    end
  end

  # Relève toutes les préférences dans la table `variables` et
  # les consignes dans @preferences
  # Note : RETURN le hash des préférences
  # Cf. User > Preferences.md
  def preferences
    @preferences = {}
    table_variables.select(where: "name LIKE 'pref_%'").each do |hpref|
      pref_id     = hpref[:name][5..-1].to_sym
      pref_value  = var_value_to_real(hpref)
      @preferences.merge!(pref_id => pref_value)
    end
    @preferences
  end

end #/User
