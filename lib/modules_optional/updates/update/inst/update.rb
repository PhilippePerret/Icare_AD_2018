# encoding: UTF-8
=begin

  Instance SiteHtml::Updates::Update
  ----------------------------------
  Une actualisation

=end
class SiteHtml
class Updates
class Update

  # Instanciation de l'update
  #
  # +foo+ L'instanciation se fait avec deux valeurs possibles :
  #   {Fixnum}  C'est l'ID de l'update enregistrée
  #   {Hash}    Ce sont les données d'une update à créer
  #
  def initialize foo
    # debug "foo: #{foo.inspect}"
    case foo
    when Fixnum
      @id = foo
    when Hash
      @data = foo
      # Si les données contiennent :correct_values, les valeurs
      # transmises seront corrigées. On fait cela pour ne pas
      # corriger toujours les valeurs, lorsque par exemple elles
      # sont transmises à l'instanciation après avoir été
      # relevées dans la table.
      human_values_to_correct_values if @data[:correct_values]
    else
      raise ArgumentError, "Mauvais argument. Fixnum ou Hash attendu."
    end
  end

  # Pour transformer les valeurs qui peuvent être raccourcies
  # ou humaines en vraies valeurs.
  def human_values_to_correct_values

    @data.delete(:correct_values)

    # La date
    # -------
    # Noter que l'update peut être antidatée
    if @data.key?(:le)
      @data[:created_at] = Data::date_humaine_to_date_real( @data.delete(:le) )
      debug "@data[:created_at] = #{@data[:created_at].inspect}"
    elsif !@data.key?(:created_at)
      @data[:created_at] = Time.now.to_i
    end

    # L'annonce
    # ---------
    # En fait, l'annonce correspond aux utilisateurs qui
    # peuvent utiliser l'update. 0, personne et aucune annonce
    # ne sera faite, 1, pour les inscrits et 2 pour les abonnés
    # seulement. Mais noter que même les updates pour les abonnées
    # seulement sont mentionnées pour les inscrits, ça leur donnera
    # peut-être envie de s'inscrire eux aussi.
    @data[:annonce] =
      case @data[:annonce]
      when NilClass                             then nil
      when 0, '0', 'false', 'FALSE'             then 0
      when 1, '1', 'true', 'TRUE', 'inscrit', 'inscrits' then 1
      else 2
      end

    # Le degré de l'importance
    if @data.key? :degre
      @data[:options] ||= ''
      @data[:options][0] = @data[:degre].to_s
      @options = @data[:options]
    end


    # debug "@data après correction : #{@data.inspect}"
  end

  # ---------------------------------------------------------------------
  #   Les données enregistrées
  # ---------------------------------------------------------------------

  def id          ; @id         ||= data[:id]                 end
  def message     ; @message    ||= data[:message]            end
  def type        ; @type       ||= data[:type]               end
  def route       ; @route      ||= data[:route]              end
  def annonce     ; @annonce    ||= data[:annonce]            end
  def options     ; @options    ||= data[:options] || ''      end
  def created_at  ; @created_at ||= data[:created_at] || Time.now.to_i  end
  def updated_at  ; @updated_at ||= data[:updated_at] end

  #
  # / fin des données
  # ---------------------------------------------------------------------

  # Création de l'actualisation dans la table
  def create
    check_data || return
    @id = table.insert(data2save)
    if @id
      flash "Update ##{@id} enregistrée avec succès."
    else
      error "Problème lors de l'enregistrement de l'update (commencer par vérifier les données dans le débug)…"
    end
  end

  # Données de l'update
  # Soit elles ont été fournies à l'instanciation pour la
  # création d'une nouvelle update, soit elles sont récupérées
  # dans la base de données.
  def data
    @data ||= begin
      id != nil || raise('Il faut fournir l’identifiant de l’update, pour la récupérer.')
      up = table.get(id)
      up != nil || raise("L'update d'ID ##{id} est inconnue…")
      up
    end
  end

  # Vérification des données transmises
  # Retourne TRUE si c'est OK, et l'update peut être
  # enregistrées, ou alors retourne false.
  def check_data
    @message = message.nil_if_empty
    @message != nil || raise("Le message ne peut pas être vide.")
    @type = type.nil_if_empty
    @type != nil || raise("Le type de l'update doit être défini (parmi : #{self.class.human_type_list})")
    type_sym = type.to_sym
    SiteHtml::Updates::TYPES.key?(type_sym) || raise("Le type d'update `#{type}` est inconnu.")
    @route = route.nil_if_empty
    @route != nil || raise("Indiquer qu'il n'y a pas de `route` avec `route:---` (pour être sûr que ça n'est pas un oubli).")
    @route = @data[:route] = nil if @route == '---'
    annonce != nil || raise("Indiquer `annonce: 0` s'il n'y a pas d'annonce à faire (ou `1` pour annonce à tout le monde et `2` pour annonce seulement aux abonnés).")
    @data[:degre] || raise("Il faut indiquer le degré de 0 à 9 de l'annonce déterminant l'importance de l'annonce. À partir de 7, l'update est annoncée sur l'accueil.")
  rescue Exception => e
    error e.message
  else
    true
  end

  # Les données à sauver
  # Noter que c'est fait une seule fois
  # Si des modifications doivent être faites, on les fait
  # par la console.
  def data2save
    @data2save ||= {
      message:      message,
      type:         type,
      route:        route,
      annonce:      annonce,
      options:      options,
      created_at:   created_at,
      updated_at:   Time.now.to_i
    }
  end

  def table
    @table ||= SiteHtml::Updates.table_updates
  end

end #/Update
end #/Updates
end #/SiteHtml
