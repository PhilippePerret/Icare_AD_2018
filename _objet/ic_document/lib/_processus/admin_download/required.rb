# encoding: UTF-8


# Pour la clarté
def icdocument
  @icdocument ||= instance_objet
end

def for_inscription?
  @for_inscription = icdocument.icetape_id.nil? if @for_inscription === nil
  @for_inscription
end

def icetape
  @icetape ||= icdocument.icetape
end

# Le dossier contenant le document (attention ! il peut en contenir plusieurs)
#
# Deux cas peuvent se produire : soit l'user est en cours de travail et
# c'est un envoi de travail sur une étape, soit ce sont les documents
# d'inscription.
#
def folder_document
  @folder_document ||= begin
    if for_inscription?
      site.folder_tmp + "download/user-#{owner.id}-signup"
    else
      # Envoi de travail
      site.folder_tmp+"download/owner-#{owner.id}-send_work-etape-#{icetape.abs_etape.numero}"
    end
  end
end
