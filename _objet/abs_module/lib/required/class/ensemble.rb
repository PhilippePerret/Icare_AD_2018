# encoding: UTF-8
class AbsModule

  SORTED_ABSMODULE_IDS = [7, 8, 12, 10, 6, 4, 15, 5, 11, 2, 3, 1, 9, 13, 14]

class << self
  # Retourne la liste (Array) des instances de module absolu
  def list
    @list ||= begin
      table.select(colonnes:[]).collect{|hmod| new(hmod[:id])}
    end
  end

  def each drequest = nil
    drequest ||= Hash.new
    table.select(drequest).each do |hmod|
      # debug "hmod = #{hmod.inspect}"
      yield hmod
    end
  end

  # Si drequest[:sorted] est vrai, alors on prend les modules dans
  # l'ordre déterminé ci-dessus
  def each_instance drequest = nil
    drequest ||= Hash.new
    sorted = !!drequest.delete(:sorted)
    drequest[:colonnes] ||= []
    if sorted
      SORTED_ABSMODULE_IDS.collect { |mod_id| new(mod_id) }
    else
      drequest.merge!(order: 'tarif ASC')
      table.select(drequest).collect { |hmod| new(hmod[:id]) }
    end.each { |mod| yield mod }
  end

end #/<< self
end #/AbsModule
