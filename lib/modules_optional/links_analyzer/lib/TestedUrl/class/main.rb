# encoding: UTF-8
class TestedPage

  class << self

    def base_url
      @base_url ||= online? ? BASE_URL : BASE_URL_LOCAL
    end

    def init
      @options              = Hash.new
      @instances            = Hash.new
      @invalides            = Array.new
      @links_count          = 0
      @routes_exclues_count = 0
      analyze_options
    end

    # Ajoute une page invalide
    #
    # On pourrait passer en revue chaque instance TestedPage,
    # mais la variable @invalides sera plus pratique.
    def add_invalide route
      @invalides << route
    end

    # Ajouter l'instance +instance+ dans la liste des instances
    #
    # Note : +route_init+ est la route ayant servi à l'instanciation
    # de l'instance, avec l'ancre si elle en contient une. C'est
    # ce qui fait que 'ma/route' et 'ma/route#avec_ancre' produisent
    # deux instances TestedPage différentes (mais qui seront mergées)
    # à la fin du check de validité.
    def << instance
      @instances.merge! instance.route_init => instance
    end

    # Retourne l'instance +route+ des instances de TestedPage
    #
    # @usage
    #     instance = TestedPage[<route>]
    def [] route
      @instances[route]
    end

    # Retourne TRUE si la route +route+ existe, c'est-à-dire si elle
    # a déjà été traité
    def exist? route
      @instances.key? route
    end


  end #/ << self
end #/TestedPage
