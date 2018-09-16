# encoding: UTF-8
=begin

  Dépôt QDD

=end

# On charge la librairie Quai des docs
site.require_objet 'quai_des_docs'


def upload_document_for which = :original
  sfile = icdocument.qdd_path(which)
  data_upload = {change_name: false, nil_if_empty: true}
  tempfile = param(:document)[which]
  result = sfile.upload(tempfile, data_upload)
  result != nil || (raise "Il faut absolument fournir le document #{which == :original ? 'original' : 'commentaires'} du document #{icdocument.original_name} !")
end

# Uploader les documents sur le quai des docs
# ------------------------------------------
# C'est la première chose car on raise à la première erreur (document
# oublié)
upload_document_for :original
icdocument.has?(:comments) && upload_document_for(:comments)

# Watcher pour que l'auteur puisse définir le partage des
# deux documents original/commentaires
owner.add_watcher(
  objet:      'ic_document',
  objet_id:   icdocument.id,
  processus:  'define_partage'
)

# Pour mettre les nouvelles données de document
data_document = Hash.new

# Marquer les documents original et commentaire déposés sur le
# QDD (s'ils existent)
opts = icdocument.options
opts = opts.set_bit(3, 1) # document original
icdocument.has?(:comments) && opts = opts.set_bit(11, 1)
data_document.merge!(options: opts)

# On doit initialiser la note estimative (cote_original)
data_document.merge!(cote_original: nil)


# On enregistre les nouvelles données du document
icdocument.set(data_document)

all_documents_traited = true
icetape.documents.split(' ').each do |doc_id|
  doc_id = doc_id.to_i
  idoc = IcModule::IcEtape::IcDocument.new(doc_id)
  # Sauf si :
  #   L'original a été déposé (4e bit à 1)
  #   et le commentaire à été déposé (12e bit à 1)
  #   ou pas de commentaire (14e bit à 1)
  # Alors le document n'est pas encore traité
  unless idoc.options[3].to_i == 1 && (idoc.options[11].to_i == 1 || idoc.options[13].to_i == 1)
    all_documents_traited = false
    break
  end
end

if all_documents_traited
  # Quand tous les documents sont traités
  # ---------------------------------------
  icetape.set(status: 6)
  flash "Tous les documents de cette série ont été déposés sur le QDD"
else
  # Quand tous les documents ne sont pas encore traités
  # ----------------------------------------------------
  no_mail_user
  flash "Document “#{icdocument.original_name}” (##{icdocument.id}) déposé sur le QDD."
end
