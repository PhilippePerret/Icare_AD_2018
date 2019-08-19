# encoding: UTF-8
=begin
Méthodes pour les objets (instances) des bases de données.

@usage

    Placer `include MethodesMySQL' dans la classe de l'objet

@requis

    La classe doit définir la méthode-propriété `table' qui retourne
    l'instance BdD::Table de la classe.

=end
module MethodesMySQL


  # Test de l'existence.
  # Se fait toujours sur l'identifiant. Surclasser la méthode
  # pour faire le test autrement
  def exist?
    table.count(where: {id: id}) > 0
  end
  alias :exists? :exist?

  # ---------------------------------------------------------------------
  #   Données qu'on retrouve presque partout
  def created_at  ; @created_at ||= get(:created_at) end
  def updated_at  ; @updated_at ||= get(:updated_at) end

  # /
  # ---------------------------------------------------------------------

  # Relève toutes les données de l'instance pour éviter les
  # requêtes à répétition et les dispatche dans les variables
  # Retourne toujours les données, sous forme de Hash
  #
  # RETURN Toutes les données relevées.
  #
  # Noter que si cette méthode est utilisée dans une boucle
  # d'instance à initialiser, les requêtes seront tout aussi à
  # répétition. Pour éviter ça, on relève toutes les données
  # lors d'une seule requête et on les envoie ici en arguments
  # pour qu'elles passent en variable d'instance
  #
  # Pour le moment, je mets ce +given_data+ pour éviter ces
  # requête à répétition, mais ça n'est pas très cohérent
  # avec le nom de la méthode (dans l'absolu, il vaudrait mieux
  # utiliser la méthode data=)
  def get_all given_data = nil
    given_data.nil? || error("Il vaut mieux utiliser la méthode `data=` que `get_all(data)` pour transmettre les données à une instance.")
    @_data = given_data # si nil => force la relève
    dispatch _data
    return _data
  end

  # Dispatche les données +hdata+ dans les variables d'instance
  def dispatch hdata
    case hdata
    when Hash
      hdata.each { |k, v| instance_variable_set( "@#{k}", v ) }
    when NilClass
      raise 'Les données à dispatcher sont vides.'
    else
      raise "Impossible de dispatcher un ensemble de données de type #{hdata.class}…"
    end
  end

  # Relève toutes les données dans la table
  # Retourne {Hash} des données ou NIL si la donnée n'existe pas
  def _data
    @_data ||= ( id.nil? ? {} : table.get(id) )
  end

  # Méthode permettant de définir les données
  # NOTE : La méthode retourne `self` pour être chainée
  def data= hdata
    @_data = hdata
    dispatch hdata
    return self
  end

  def select params
    table.select( params )
  end


  # +key+ Symbol (la propriété) ou liste de Symbol
  # Retourne un Hash (si liste de Symbol) ou la valeur (si Symbol)
  def get keys
    want_unique_data = false == keys.instance_of?(Array)
    keys = [keys] if want_unique_data

    # Le Hash qui sera retourné, ou pour contenir la
    # données unique à retourner
    retour = Hash.new

    # On essaie d'abord de les obtenir dans les données qui
    # ont peut-être été relevées par un get_all
    @_data ||= Hash.new
    rest_keys = Array.new
    keys.each do |key|
      if @_data.key?( key )
        retour.merge!( key => @_data[key] )
      else
        rest_keys << key
      end
    end

    # On doit relever dans la table les clés manquantes
    unless rest_keys.empty?
      retour_table = table.select( colonnes: keys, where: { id: id } ).first
      retour.merge!(retour_table) unless retour_table.nil?
    end

    # Le retour suivant les cas
    if retour.nil?
      return nil
    elsif want_unique_data
      return retour[keys.first]
    else
      return retour
    end
  rescue Exception => e
    debug e
    error e
  end

  # Sauve les données dans la donnée
  # +hdata+ {Hash} des données à sauvegarder
  # Alias def set
  def set hdata = nil
    hdata ||= _data
    retour =
      if @id.nil?
        @id = table.insert( hdata )
      else # Update ou Insert
        # On ajoute toujours, maintenant, la date d'actualisation
        # Attention, ça peut produire une erreur si la table ne contient
        # Pas cette colonne…
        hdata.key?(:updated_at) || hdata.merge!(updated_at: Time.now.to_i)
        table.set( id, hdata )
      end
    # On actualise les variables d'instance et les données
    # déjà consignées dans @_data
    @_data ||= Hash.new
    hdata.each do |k, v|
      instance_variable_set("@#{k}", v)
      @_data[k] = v
    end
  rescue Exception => e
    error e
  ensure
    return retour
  end
  alias :save :set

  # Détruit la donnée
  # Alias def remove
  def delete
    if id.instance_of? Integer
      table.delete(id)
    else
      table.delete(where: { id: id })
    end
  rescue Exception => e
    error e
  end
  alias :remove :delete

end
