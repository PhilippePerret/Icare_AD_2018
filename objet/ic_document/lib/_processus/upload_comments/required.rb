# encoding: UTF-8

def icdocument
  @icdocument ||= instance_objet
end

def icetape
  @icetape ||= icdocument.icetape
end

def inscription?
  @for_inscription = icdocument.inscription? if @for_inscription === nil
  @for_inscription
end


# Dossier où se trouvent les documents commentaires à
# télécharger par l'icarien
def folder_download
  @folder_download ||= begin
    site.folder_tmp +
      if inscription?
        "download/user-#{owner.id}-signup"
      else
        "download/owner-#{owner.id}-upload_comments-#{owner.icmodule.id}-#{icetape.id}"
      end
  end
end
