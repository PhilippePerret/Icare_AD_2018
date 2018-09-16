# encoding: UTF-8

# L'icarien courant, quand ce n'est pas une liste demandée
def icarien
  @icarien ||= Icarien.new(site.current_route.objet_id)
end
