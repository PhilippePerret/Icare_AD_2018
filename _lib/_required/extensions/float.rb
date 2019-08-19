# encoding: UTF-8
class ::Float

  class << self
    def devise
      @devise ||= "€"
    end
    def devise= value
      @devise = value
    end
    def separateur_decimal
      @separateur_decimal ||= ","
    end
    def separateur_decimal= value
      @separateur_decimal = value
    end
  end # << self

  def rjust( len, remp = " "); self.round(2).to_s.rjust(len, remp) end
  def ljust( len, remp = " "); self.round(2).to_s.ljust(len, remp) end

  # Retourne le float à la française, avec une virgule en
  # séparateur. NOter que si le float se termine par ".0", la
  # virgule et le zéro sont supprimés
  def as_fr
    t = "#{self}"
    unites, decimales = t.split('.')
    nombre_string = unites
    nombre_string += "#{self.class::separateur_decimal}#{decimales}" unless decimales == "0"
    return nombre_string
  end

  # {String} Retourne le flottant comme un tarif, avec le bon
  # séparateur et la bonne devise.
  def as_tarif
    t = "#{self}"
    euros, centimes = t.split('.')
    centimes += "0" if centimes.length < 2
    "#{euros}#{self.class::separateur_decimal}#{centimes}#{self.class::devise}"
  end

end
