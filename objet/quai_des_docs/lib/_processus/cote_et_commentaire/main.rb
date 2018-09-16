# encoding: UTF-8
=begin
  Processus permettant à l'user de faire un commentaire sur un
  double document téléchargé
=end


def data_original
  @data_original ||= param(:document_original)
end
def data_comments
  @data_comments ||= param(:document_comments)
end
# Commentaire général sur le document (noter qu'il y a un seul
# commentaire pour la paire de document, contrairement aux cotes qui
# sont attribuées à chaque document)
def document_coms
  @document_coms ||= param(:document_coms).nil_if_empty
end


# Cote du document original (if any)
if icdocument.has?(:original)
  cote = data_original[:cote].to_i
  cote_original = cote > 0 ? cote.to_s : '-'
end
# Cote du document commentaire (if any)
if icdocument.has?(:comments)
  cote = data_comments[:cote].to_i
  cote_comments = cote > 0 ? cote.to_s : '-'
end

def hlecture
  dbtable_lectures.get(where:{user_id: user.id, icdocument_id: icdocument.id})
end

if hlecture.nil?
  error 'Vous ne possédez aucune fiche de lecture pour ce document… Vous ne pouvez pas le coter ou le commenter, voyons…'
else
  new_data = Hash.new
  new_data.merge!(
    updated_at:   Time.now.to_i,
    cotes:        "#{cote_original}#{cote_comments}"
  )
  new_data.merge!(comments: document_coms) if document_coms != nil

  # === On enregistre ces nouvelles données ===
  dbtable_lectures.update(hlecture[:id], new_data)

  # Message de remerciement
  mess = 'Merci pour '
  if new_data[:cotes] != '--'
    mess << 'la cote'
    mess << ' et ' if new_data[:comments]
  end
  mess << 'le commentaire' if new_data[:comments]
  mess << " concernant ces documents de #{auteur.pseudo}."
  flash mess
end
