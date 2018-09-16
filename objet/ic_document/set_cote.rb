# encoding: UTF-8
raise_unless_identified

debug "-> set_cote.rb"


com_id = param(:com_id).nil_if_empty

nouveau_commentaire = com_id.nil?

cote_original = param(:cote_original).to_i
cote_original > 0 || cote_original = '-'
cote_comments = param(:cote_comments).to_i
cote_comments > 0 || cote_comments = '-'

commentaire = param(:comments).nil_if_empty

data_lecture = {
  user_id:        user.id,
  icdocument_id:  site.current_route.objet_id,
  cotes:          "#{cote_original}#{cote_comments}",
  comments:       commentaire,
  updated_at:     Time.now.to_i
}

table = IcModule::IcEtape::IcDocument.table_lectures
if nouveau_commentaire
  data_lecture.merge!(created_at: Time.now.to_i)
  table.insert(data_lecture)
else
  table.update(com_id, data_lecture)
end

flash "Merci pour ce commentaire et ces cotes, #{user.pseudo} !"

redirect_to :last_page
