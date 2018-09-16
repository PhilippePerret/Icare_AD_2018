# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument
class << self

  # Crée un enregistrement pour le document {SuperFile} sfile avec les
  # données +data+
  # +sfile+   {SuperFile} du fichier (qui doit exister)
  # +args+    {Hash} Données spécifiant éventuellement :
  #           :icmodule_id
  #           :icetape_id
  #           :user_id / :user
  #           Et toute autre donnée qu'on peut trouver dans la table
  #
  # Noter qu'en général un document est lié à une étape et un module mais
  # que ça n'est pas toujours le cas comme pour les documents de présentation
  #
  # RETURN L'instance IcModule::IcEtape::IcDocument créée
  #
  def create sfile, ddocument = nil
    ddocument ||= Hash.new
    ddocument[:user_id]       ||= user.id
    ddocument[:abs_module_id] ||= 0 # <=> inscription
    ddocument[:abs_etape_id]  ||= 0 # <=> inscription
    ddocument[:doc_affixe]    ||= sfile.affixe.as_normalized_filename
    ddocument[:original_name] ||= sfile.name.as_normalized_filename
    ddocument[:time_original] ||= sfile.mtime.to_i
    ddocument[:created_at]    ||= Time.now.to_i
    ddocument[:updated_at]    ||= Time.now.to_i
    ddocument[:options]       ||= default_options
    newdoc_id = table.insert(ddocument)
    return new(newdoc_id)
  end

end #/<< self
end #/IcDocument
end #/IcEtape
end #/IcModule
