# encoding: UTF-8
class TestedPage
  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # IDentifiant de l'instance dans la classe
  #
  # Pour la récupérer :
  #     instance = TestedPage[<id>]
  #
  attr_accessor :id

  attr_reader :route_init, :route, :url_anchor

  # Liste Array des erreurs éventuellement rencontrées
  attr_reader :errors

  # Instanciation d'une url
  def initialize route
    @route_init = route.strip
    decompose_route
    self.class << self
    @errors = Array.new
  end

end #/TestedPage
