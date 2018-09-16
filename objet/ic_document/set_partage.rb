# encoding: UTF-8
raise_unless_identified

def icdocument
  @icdocument ||= begin
    IcModule::IcEtape::IcDocument.new(site.current_route.objet_id)
  end
end

raise_unless user.admin? || user.id == icdocument.user_id

# 4/12 doivent être mis à 1 pour indiquer que le partage
# est défini.
# bit 1 (2e) : niveau partage original
# bit 9 (10e) : niveau partage comments
bitoshared = param(:doriginal_sharing).to_i
bitcshared = param(:dcomments_sharing).to_i

icdocument.partager(original: bitoshared, comments: bitcshared)

redirect_to :last_page
