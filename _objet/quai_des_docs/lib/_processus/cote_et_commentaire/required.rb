# encoding: UTF-8


# Document concerné par la cote et le commentaire
def icdocument
  @icdocument ||= begin
    site.require_objet 'ic_document'
    IcModule::IcEtape::IcDocument.new(objet_id)
  end
end

# Auteur du document
def auteur
  @auteur ||= icdocument.owner
end
# L'étape du document
def icetape
  @icetape ||= icdocument.icetape
end
