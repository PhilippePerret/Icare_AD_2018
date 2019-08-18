# encoding: UTF-8
=begin

  Module étendant la classe de l'user par rapport au quai des docs

=end
class User

  # Retourne le nombre de documents téléchargés par l'user, donc son
  # nombre de lectures
  def nombre_lectures
    table_lectures.count(where:{user_id: self.id})
  end

  # RETURN true si l'user a lu le document d'identifiant +docid+
  def lu? docid
    table_lectures.count(where:{user_id: self.id, icdocument_id: docid}) > 0
  end

  def table_lectures; @table_lecture ||= QuaiDesDocs.table_lectures end
end
