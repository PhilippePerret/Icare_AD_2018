# encoding: UTF-8
=begin
Module qui ajoute des méthodes pour checker les données de tout type

=end
module DataChecker
  class DataCheckError < StandardError
    attr_reader :code
    attr_reader :expected
    attr_reader :actual
    def initialize code_err, expected_value = nil, actual_value = nil
      @code     = code_err
      @expected = expected_value
      @actual   = actual_value
    end
  end

  class DataChecker
    include Singleton

    attr_accessor :objet
    attr_accessor :definition
    attr_accessor :options
    attr_accessor :ok
    attr_accessor :errors

    def run
      self.ok     = true
      self.errors = Hash.new
      objet.epure
      set_value_like_type
      check_objet
      objet
      return self
    end

    # = main check =
    # La méthode principale qui gère le check des valeurs
    # Noter que lorsqu'on passe par ici, les valeurs ont été épurées
    # et mises dans leur type défini par la `checks`
    def check_objet
      definition.each do |prop, dcheck|
        dcheck[:hname] ||= prop.inspect
        dcheck[:hname] = "La valeur de #{dcheck[:hname]}"
        check_property prop, dcheck
      end
    end

    DATA_ERREURS = {
      10000 => "%{hname} doit être définie.",
      20001 => "%{hname} devrait avoir une longueur minimum de %{expected} (la longueur est de %{actual}).",
      20002 => "%{hname} devrait être supérieur ou égal à %{expected} (sa valeur est de %{actual}).",
      20011 => "%{hname} devrait avoir une longueur maximale de %{expected} (la longueur est de %{actual}).",
      20012 => "%{hname} devrait être inférieur ou égal à %{expected} (sa valeur est de %{actual}).",
      30000 => "Le mail “%{actual}” est invalide."
    }

    # Check de la propriété +prop+ par le hash +dcheck+
    def check_property prop, dcheck
      # La valeur a checker
      value = objet[prop]
      # Nécessité de définition de la propriété de l'objet
      raise DataCheckError::new(10000) if dcheck[:defined] && value.nil?
      check_value_min( dcheck[:type], dcheck[:min], value ) if dcheck[:min]
      check_value_max( dcheck[:type], dcheck[:max], value ) if dcheck[:max]
      check_if_mail(value) if dcheck[:mail] == true
    rescue DataCheckError => e
      self.ok = false
      errcode = e.code
      errmess = (DATA_ERREURS[errcode] || "Code erreur non défini : #{err_code}") % {
        hname:    dcheck[:hname],
        expected: e.expected,
        actual:   (e.actual || value)
      }
      self.errors.merge!(prop => {
        err_code: errcode, err_message: errmess
        })

    rescue Exception => e
      self.ok = false
      add_error :rescue_in_check_property, e
    end

    # ---------------------------------------------------------------------
    #   Les méthodes de check
    # ---------------------------------------------------------------------
    def check_value_min type, valmin, value
      bad = case type
      when :fixnum, :float, :bignum then value < valmin
      when :string then value.length < valmin
      else false
      end
      if bad
        case type
        when :string then raise DataCheckError::new( 20001, valmin, value.length )
        else raise DataCheckError::new(20002, valmin)
        end
      end
    end
    def check_value_max type, valmax, value
      bad = case type
      when :fixnum, :float, :bignum then value > valmax
      when :string then value.length > valmax
      else false
      end
      if bad
        case type
        when :string then raise DataCheckError::new( 20011, valmax, value.length )
        else raise DataCheckError::new(20012, valmax)
        end
      end
    end
    REG_MAIL = /([a-zA-Z0-9_\.-]+)@([a-zA-Z0-9_\.-]+)\.([a-z]{1,6})/
    def check_if_mail value
      raise DataCheckError::new(30000, nil, nil) unless value.match(REG_MAIL)
    end

    # / fin des méthodes de check
    # ---------------------------------------------------------------------

    # Transforme les valeurs suivant le type défini
    def set_value_like_type
      objet.each do |prop, value|
        next if value.nil? # rien à faire si la valeur est nil
        next if definition[prop].nil? # propriété non définie
        type = definition[prop][:type]
        next if type.nil? # type non défini
        value = case type
        when :mail then
          definition[prop][:type] = :string
          definition[prop][:mail] = true
          value
        when :fixnum, :bignum then value.to_i
        when :float  then value.to_f
        else value
        end
        objet[prop] = value
      end
    end

    def add_error key, err
      self.errors.merge!(key => err.message + "\n" + err.backtrace.join("\n"))
    end

  end


  class ::Hash

    # = main =
    #
    # @usage <objet hash>.check_data( <{définition checks}> )
    def check_data checks_definition, options = nil
      datachecker = DataChecker.instance
      datachecker.objet   = self
      datachecker.definition  = checks_definition
      datachecker.options = options || Hash.new
      datachecker.run
    rescue Exception => e
      datachecker.add_error :rescue, e
    ensure
      return datachecker
    end

    # Strip toutes les valeurs stripable et les met à
    # nil si elles sont vides
    def epure
      keys.each do |key|
        next unless self[key].respond_to?(:nil_if_empty)
        self[key] = self[key].nil_if_empty
      end
    end
  end

end
