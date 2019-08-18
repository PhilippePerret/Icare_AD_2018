# encoding: UTF-8
class Frigo
class Discussion
class Message


  def content       ; @content        ||= get(:content)         end
  def discussion_id ; @discussion_id  ||= get(:discussion_id)   end
  def auteur_ref    ; @auteur_ref     ||= get(:auteur_ref)      end

  # ---------------------------------------------------------------------
  #   Données volatiles
  # ---------------------------------------------------------------------

  def discussion
    @discussion ||= begin
      Frigo::Discussion.new(discussion_id)
    end
  end

  # Url avec l'ancre vers le message
  def url
    "#{site.distant_url}/bureau/#{frigo.owner_id}/frigo#mess_#{id}"
  end


  def table ; @table ||= dbtable_frigo_messages end

end #/Message
end #/Discussion
end #/Frigo
