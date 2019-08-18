# encoding: UTF-8
class Frigo
class << self

  def current
    @current ||= begin
      Frigo.new(site.current_route.objet_id)
    end
  end

  # = main =
  #
  # Méthode principale, appelée par la vue, permettant d'afficher
  # toutes les discussions publiques du bureau courant.
  #
  # Elle retourne le code HTML de toutes les discussions.
  #
  def discussions_publiques
    whereclause = ["owner_id = #{frigo.owner_id}"]
    if user.identified?
      whereclause << "CAST(SUBSTRING(options,1,1) AS SIGNED) > 0"
    else
      whereclause << "SUBSTRING(options,1,1) = '2'"
    end
    request = {
      where: whereclause.join(' AND '),
      colonnes: []
    }
    dbtable_frigo_discussions.select(request).collect do |hdis|
      dis = Frigo::Discussion.new(hdis[:id]).display
    end.join.in_div(class: 'discussions')
  end
end #/<< self
end #/Frigo
