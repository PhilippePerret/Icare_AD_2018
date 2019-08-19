# encoding: UTF-8
# Extension de la class Hash

class Hash

  # Pour un Hash, ce sont la clé et une propriété :hname ou
  # :titre qui seront utilisés respectivement
  # comme valeur (clé) et titre.
  def in_select options = nil
    self.collect do |hid, hdata|
      [hid, (hdata[:hname] || hdata[:titre])]
    end.in_select(options)
  end

  # Retourne NIL si le Hash est vide, sinon
  # le hash lui-même
  def nil_if_empty
    self.empty? ? nil : self
  end
  def nil_or_empty?
    self.count == 0
  end

  ##
  # Retourne le hash sous forme de array
  def to_array
    self.collect{|k,v| v}
  end

  # Merge profond simple
  def deep_merge hash
    merged = self
    hash.each do |k, v|
      if v.class == Hash
        merged = merged.merge( k => merged[k].deep_merge(v) )
      else
        merged = merged.merge k => v
      end
    end
    merged
  end

  # Pour un affichage plain (pas HTML), affiche le hash de façon lisible, chaque
  # clé passant à la ligne + des retraits.
  # @usage : puts <hash>.pretty_inspect
  # @param  retrait {Integer|String}
  #         Le retrait à appliquer à chaque donnée
  def pretty_inspect retrait = 0
    retrait_str =  "  " * retrait
    str = "#{retrait_str}{\n"
    self.each do |k, v|
      v = case k
      when :created_at, :updated_at, :ended_at
        case v
        when NilClass then nil
        when Integer   then v.as_human_date(true, true, ' ') + " (real: #{v})"
        else v
        end
      else v end
      v = case v
      when Hash then "\n" + v.pretty_inspect(retrait + 1)
      else v.inspect end
      str += retrait_str + "#{k.inspect} => " + v  + "\n"
    end
    str + "#{retrait_str}}"
  end

  # Plutôt une méthode de débuggage : pour faire un affichage
  # plus lisible d'un Hash.
  def pretty_puts deep = 1
    self.collect do |key, value|
      '<div>' + ("&nbsp;&nbsp;"*deep) + "#{key.inspect} => " +
      case value.class.to_s
      when "Hash" then value.pretty_puts(deep + 1)
      else
        value.inspect
      end +
      '</div>'
    end.join("")
  end

  # Remplace les "true", "false", "null" par true, false, nil
  def values_str_to_real
    self.each do |k,v|
      v = case v.class.to_s
      when 'Hash', 'Array' then v.values_str_to_real
      when 'String' then
        case v
        when "true" then true
        when "false" then false
        when "nil", "null" then nil
        else v
        end
      else v
      end
      self[k] = v
    end
  end

  # Permet de remplacer les clés 'string' par :string
  # Utile par exemple pour des données JSON récupérées
  def to_sym
    hash_ruby = {}
    self.each do |k, v|
      k = k.to_s[0..-3] if k.to_s.end_with? '[]'
      v_ruby =  case v.class.to_s
                  when 'Hash'   then v.to_sym
                  when 'Array'  then
                    v.collect do |e|
                      case e.class.to_s
                        when 'Hash', 'Array' then e.to_sym
                        else e
                      end
                    end
                  else v
                end
      k = k.to_sym unless k.instance_of?(Integer)
      hash_ruby = hash_ruby.merge( k => v_ruby )
    end
    hash_ruby
  end

  # Remplace les clés par des nombres. Attention, ne vérifie
  # pas que ça en soit donc peut produire une erreur
  # Note: Seules les clés de premier niveau sont traitées
  def with_key_fixnum
    new_hash = Hash.new
    self.each { |k, v| new_hash.merge! k.to_s.to_i => v }
    new_hash
  end

end
