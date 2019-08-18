# encoding: UTF-8
class Admin
class Users
class << self

  def exec_inject_document
    nom_doc = medium_value
    nom_doc != nil  || raise('Il faut donner le nom du fichier.')
    nom_doc = nom_doc.as_normalized_filename
    icarien.icmodule   || raise('L’icarien choisi ne possède pas de module courant. Impossible de lui injecter un document d’étape.')
    icarien.icetape    || raise('L’icarien choisi ne possède pas d’étape courant. Impossible de lui injecter un document.')
    absmodule = icarien.icmodule.abs_module
    icetape   = icarien.icetape
    absetape  = icetape.abs_etape

    # Si le statut de l'étape est supérieur à 3, i.e. que
    # des commentaires ont déjà été remis, il est impossible
    # d'ajouter des documents. Il faut forcément passer à
    # une étape suivante, certainement l'étape juste après.
    if icetape.status > 3
      error "Le statut de l'étape (#{icetape.status}) ne permet pas d'injecter des documents dans cette étape (des commentaires ont déjà été reçus).<br><br>Il faut passer #{icarien.pseudo} (##{icarien.id}) à l'étape suivante (une étape intermédiaire) et ajouter les documents à cette étape intermédiaire."
    else
      # Le statut de l'étape permet d'injecter le document
      #
      # On crée le document à l'aide de la procédure normale.
      site.require_objet 'ic_document'
      IcModule::IcEtape::IcDocument.require_module 'create'
      new_doc_id = IcModule::IcEtape::IcDocument.create(icetape, nom_doc, {watcher_upload_comments: true})

      flash "Documnent “#{nom_doc}” (##{new_doc_id}) injecté dans l'étape #{absetape.numero}-#{absetape.titre} du module #{absmodule.name} de #{icarien.pseudo}."+
      "<br>Un watcher a été créé pour le commenter"+
      "<br>Une activité a été produite pour cet envoi"
    end
  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
