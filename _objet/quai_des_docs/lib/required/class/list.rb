# encoding: UTF-8
class QuaiDesDocs
class << self

  attr_reader :nombre_documents_found

  # Retourne la liste des documents répondant au filtre +filtre+
  #
  # +filtre+
  #   Toutes les propriétés d'un document peuvent être utilisés par le
  #   filtre, pour le moment par égalité. Par exemple, si le filtre
  #   contient :abs_etape_id => 526, seuls seront retournés les documents
  #   de l'étape absolue 526.
  #   Pour le moment, on peut le penser comme la donnée de request, donc
  #   on met dans :where les conditinos, dans :order le tri, etc.
  #
  # +options+ {Hash} permettant de définir la list ou le retour
  #   :as     Définit le format de retour des éléments de la liste
  #           retournée.
  #           :instance       Des instances d'icdocuments (défaut)
  #           :hash           Des hash contenant toutes les données
  #           :id             Seulement les identifiants
  #
  # Note :
  #   * Le nombre de documents trouvés est mis dans la variable
  #     @nombre_documents_found qu'on peut obtenir par :
  #     QuaiDesDocs.nombre_documents_found
  # 
  def list filtre = nil, options = nil
    options ||= Hash.new

    as = options.delete(:as) || :instances

    # Construire les données de requête
    if filtre && false == filtre.key?(:where)
      filtre = {where: filtre}
    end
    drequest = filtre || Hash.new

    cols =
      case as
      when :instance, :id then [] # :id toujours ajouté
      else nil # :hash
      end
    cols ||= Array.new
    cols << :abs_module_id # pour éviter les documents d'inscription
    drequest.merge!(colonnes: cols)

    # N0002
    res =
      dbtable_icdocuments.select(drequest).collect do |hdoc|
        hdoc[:abs_module_id] > 0 || next
        hdoc
      end.compact

    @nombre_documents_found = res.count

    # On retourne le résultat
    case as
    when :instance
      site.require_objet 'ic_document'
      res.collect{|h| IcModule::IcEtape::IcDocument.new(h[:id])}
    when :id
      res.collect{|h| h[:id]}
    when :hash
      res
    end
  end

end #/<< self
end #/QuaiDesDocs
