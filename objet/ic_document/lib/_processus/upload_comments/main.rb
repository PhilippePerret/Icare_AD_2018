# encoding: UTF-8
=begin

  Procédure de dépôt des commentaires
  -----------------------------------

  Il faut déjà considérer deux cas :
    1. Je remets les commentaires sur le document
    2. Je ne remets aucun commentaire sur le document

  - La notification user lui dit que son document est en lecture
  - la notification admin présente un champ pour envoyer le commentaire
  - le main traite le formulaire d'envoi du commentaire
  - le mail user l'informe que son commentaire peut être chargé sur le site

  Watcher suivant : user_download

=end

def param_comments
  @param_comments ||= param(:comments)
end

# Return true si le document a été commenté
def commented?
  @is_commented = !(param_comments[:none] == 'on') if @is_commented === nil
  @is_commented
end

# Les données modifiées du document
data_document = Hash.new


if commented?

  # ---------------------------------------------------------------------
  #
  #       DOCUMENT COMMENTÉ
  #
  # ---------------------------------------------------------------------

  # Download du document sur le site
  sfile = folder_download + 'titre_provisoire'
  params = {change_name: true, nil_if_empty: true}
  res = sfile.upload(param_comments[:file], params)
  res != nil || (raise 'Il faut fournir le document commentaire (ou cocher la case `Pas de commentaires`).')
  sfile.exist? || (raise "Le fichier #{sfile} est introuvable, malheureusement, il n'a pas été uploadé.")

  # Créer le watcher suivant
  owner.add_watcher(
    objet:      'ic_document',
    objet_id:    objet_id,
    processus:  'user_download_comments',
    data:       sfile.name
  )

  # On met que le commentaire existe
  opts = icdocument.options.set_bit(8,1)
  data_document.merge!(options: opts)

  # Date de commentaire
  data_document.merge!(time_comments: Time.now.to_i)

  flash "Les commentaires du document “#{icdocument.original_name}” (##{icdocument.id}) ont été enregistrés. L'auteur a été prévenu par mail."
else

  # ---------------------------------------------------------------------
  #
  #       DOCUMENT NON COMMENTÉ
  #
  # ---------------------------------------------------------------------

  # On met le cycle de vie du document commentaires à fin
  # C'est le 12e bit qui doit être mis à 1
  # Attention : avant, c'était le 6e bit qui était à 1, mais en fait le
  # cycle de vie du document original n'est pas du tout fini puisqu'il faut
  # le déposer sur le Quai des docs et définir son partage.
  opts = icdocument.options.set_bit(13,1)
  data_document.merge!(options: opts)

  # Ne pas envoyer le mail à l'icarien pour ce document.
  no_mail_user

  flash "Sans commentaires, ce document “#{icdocument.original_name}” (##{icdocument.id}) a fini son cycle."
end

# On enregistre les données modifiées du document
icdocument.set(data_document)

# Contrairement au téléchargement des originaux par l'administrateur,
# on passe le statut de l'étape à 4 dès la réception d'un commentaire,
# car tous les documents ne seront pas forcément commentés.
all_comments_received = true
icetape.documents.split(' ').each do |docid|
  idoc = IcModule::IcEtape::IcDocument.new(docid.to_i)
  opts = idoc.options
  if opts[8].to_i == 0 && opts[13].to_i != 1
    all_comments_received = false
    break
  end
end
all_comments_received && begin
  # Quand tous les commentaires ont été envoyés ou annulés
  site.require_objet 'actualite'
  SiteHtml::Actualite.create(
    user_id: owner.id,
    message: "Phil transmet ses commentaires à <strong>#{owner.pseudo}</strong>."
  )
  icetape.set(status: 4)
  # Une tache pour l'administrateur
  site.dbm_table(:hot, 'taches').insert(
    tache:      "Déposer les documents de #{owner.pseudo} sur le quai des docs",
    echeance:   Time.now.to_i + 4.days,
    created_at: Time.now.to_i,
    updated_at: Time.now.to_i
  ) rescue nil

end
