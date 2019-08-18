# encoding: UTF-8
=begin
Module de traitement de données spéciales.

Ce module a été inauguré pour le traitement des données des
commandes de console qui peuvent être mises sous la forme :
    `prop:valeur de la prop autreprop: autre valeur de l'autre propre etc.`
    Cf. semicolon_data_in
=end

class PHData
class << self


  # Méthode qui reçoit une date quelconque, sous une forme
  # humaine ou pseudo humaine, et retourne le nombre de
  # secondes (timestamp) correspondant.
  #
  # Les valeurs possibles sont par exemple :
  #   auj, today, aujourd'hui     = aujourd'hui
  #   dem, demain, tomorrow       = demain
  #   après-demain, +2            = après-demain
  #
  #   + <nombre de jours>   = nombre de jours à partir de maintenant
  #   - <nombre de jours>   = nombre de jours avant maintenant
  #
  # Cette méthode sert notamment pour la console, les commandes
  # pour les tâches ou pour les updates.
  # Mettre +dformat+ à "%d %m %Y" pour obtenir "JJ MM YYYY"
  def date_humaine_to_date_real hvalue, dformat = nil
    hvalue = hvalue.strip if hvalue.instance_of?(String)
    rval = case hvalue
    when Integer
      hvalue
    when "auj", "today", "aujourd'hui" then
      Time.now
    when "dem", "demain", "tomorrow" then
      (Time.now + 1.day)
    when "après-demain"
      (Time.now + 2.days)
    when /^\+ ?([0-9]+)$/
      nombre_jours = hvalue.scan(%r{^\+ ?([0-9]+)$})[0][0].to_i
      (Time.now + nombre_jours.days)
    when /^\- ?([0-9]+)$/
      nombre_jours = hvalue.scan(%r{^\- ?([0-9]+)$})[0][0].to_i
      (Time.now - nombre_jours.days)
    when /^[0-9]{1,2} [0-9]{1,2} [0-9]{2,4}$/
      jour, mois, annee = hvalue.split(' ').collect{ |c| c.to_i }
      annee = annee + 2000 if annee < 100
      Time.new(annee, mois, jour).to_i
    else
      hvalue.to_i
    end

    if dformat.nil?
      rval.to_i
    else
      rval.strftime(dformat)
    end

  end

  # @usage :
  #     hash_data = PHData::by_semicolon_in line_data_string
  #
  # Reçoit une chaine de données qui ressemble à :
  #   "pour:Phil le: auj tache: Ceci est la tache à exécuter : pour voir."
  # et retourne un Hash contenant :
  #   {
  #     pour: "Phil", le: "auj", tache: "Ceci est etc."
  #   }
  # Les clés (:pour, :le, etc.) doivent :
  #     * ne contenir que des lettres maj/min et des chiffres
  #     * doivent être collées aux ":"
  #     * doivent être précédés par une espace
  def by_semicolon_in data_str
    # On ajoute une balise de fin "fin:" pour que l'expression
    # régulière puisse capter le dernier élément de data_str
    data_str = " #{data_str} fin:"
    # Le hash de données qui sera revoyé
    hdata = Hash.new
    data_str.scan(/ ([a-zA-Z0-9]+)\:(.*?)(?= [a-zA-Z0-9]+\:)/).to_a.each do |paire|
      key, value = paire
      hdata.merge!(key.to_sym => value.strip.freeze)
    end
    return hdata
  end

end #/<< self
end #/PHData
