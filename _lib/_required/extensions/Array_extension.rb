# encoding: UTF-8
class ::Array

  # Sert pour obtenir facilement un array lorsque l'on veut
  # obtenir un array depuis un string, un fixnum, etc. ou un
  # array. Si l'élément est déjà un array, on n'a rien à faire
  # d'autre que de le renvoyer.
  def in_array
    self
  end

  # Pour un Array constitué de Hashs qui contiennent la propriété :id,
  # on produit un Hash avec cet :id en clé
  def as_hash_with_id
    debug "self: #{self.inspect}"
    self.empty? && (return {})
    self.first.instance_of?(Hash) || (raise 'Les éléments devraient être des Hash')
    self.first.key?(:id) || (raise 'Les éléments Hash devraient définir la propriété :id pour être transformé en Hash-id.')
    htot = Hash.new
    self.each{ |h| htot.merge!(h[:id] => h) }
    return htot
  end

  def to_sym
    self.collect do |e|
      case e
      when Hash, Array then e.to_sym
      else e
      end
    end
  end

  def pretty_inspect
    "[\n" +
    self.collect do |item|
      case item
      when Hash, Array then item.pretty_inspect
      else item.inspect
      end
    end.join("\n") +
    "\n]"
  end

  ##
  #
  # Reçoit une liste de paths absolue et retourne la même
  # liste avec des paths relatives par rapport à l'application
  #
  # NOTE
  #
  #   * La méthode `as_relative_path' doit être implémenté
  #     pour l'extension String
  #
  def as_relative_paths
    self.collect { |p| p.as_relative_path }
  end
  alias :as_relative_path :as_relative_paths

  # Prend la liste {Array}, sépare toutes les valeurs par des virgules sauf
  # les deux dernières séparées par un "et"
  def pretty_join
    all   = self.dup
    return "" if all.count == 0
    return all.first.to_s if all.count == 1
    last  = all.pop.to_s
    all.join(', ') + " et " + last
  end

  def nil_if_empty
    self.empty? ? nil : self
  end

  # Retourne la note sur vingt de [note, note maximale] en gardant
  # +decimales+ nombre après la virgules.
  # Par exemple :
  #   [15, 20].sur_vingt    # => 15.0
  #   [150, 200].sur_vingt  # => 15.0
  #   [10.to_f/3, 20].sur_vingt(3)  # => 3.333
  def sur_vingt decimales = 2
    (self.first.to_f * 20 / self.last.to_f).round(decimales)
  end


end
