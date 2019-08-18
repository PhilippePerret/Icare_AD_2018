# encoding: UTF-8
Bureau.require_module 'frigo'

# Le frigo courant
# objet_id de la route définit l'identifiant du propriétaire du
# frigo tandis que user est l'interlocuteur.
def frigo ; Frigo.current end

case param(:operation)
when 'save_message_frigo'
  # Pour sauver un message frigo
  Frigo::Discussion.new(param(:frigo_discussion_id).to_i).create_message
when 'create_of_retreive_discussion'
  # Pour identifier l'interlocuteur ou créer une nouvelle
  # discussion avec lui (quand je dis "nouvelle", je veux dire que c'est
  # une création de nouvelle discussion, mais on ne peut créer qu'une
  # seule conversation par utilisateur — même s'il est possible de
  # contourner la restriction quand on est icarien : une discussion en tant
  # qu'icarien et une autre sans être identifié)
  Frigo::Discussion.create_of_retreive
when 'remove_discussion'
  Frigo::Discussion.new(param(:discussion_id).to_i).remove
when 'set_partage_discussion'
  Frigo::Discussion.new(param(:discussion_id).to_i).set_partage
end
