# encoding: UTF-8


def sharing ; @sharing ||= param(:sharing) end

opts = icdocument.options
opts = opts.set_bit(1, sharing[:original].to_i)
opts = opts.set_bit(9, (sharing[:comments] || 3).to_i)
# On marque le cycle du document achevé
opts = opts.set_bit(5, 1)
opts = opts.set_bit(13, 1)
# Enregistrement des options
icdocument.set(options: opts)


all_documents_traited = true
icetape.documents.split(' ').each do |doc_id|
  icdoc = IcModule::IcEtape::IcDocument.new(doc_id.to_i)
  if icdoc.options[1].to_i == 0 || icdoc.options[9].to_i == 0
    all_documents_traited = false
    break
  end
end

if all_documents_traited

  icetape.set(status: 7)
  site.require_objet 'actualite'
  SiteHtml::Actualite.create(user_id: owner.id, message: "<strong>#{owner.pseudo}</strong> définit le partage de ses documents de l'étape #{numero_etape} de son module “#{module_name}”.")

  # Actualisation des statistiques
  Atelier.remove_statistiques_file

  flash "Merci d'avoir défini le partage de tous vos documents de l'étape #{numero_etape}."

else
  # Quand tous les documents ne sont pas traités
  no_mail_admin
  flash "Merci pour la définition du partage de “#{icdocument.original_name}”."
end
