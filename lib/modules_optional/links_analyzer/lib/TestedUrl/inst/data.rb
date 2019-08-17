# encoding: UTF-8
class TestedPage

  # Retourne un Hash contenant les données minimales à enregistrer
  # dans le fichier Marshal
  def data_marshal
    h = Hash.new
    [:url, :route_init, :route, :call_count, :call_froms, :call_texts,
      :depths
    ].each do |prop|
      h.merge!( prop => self.send(prop) )
    end
    return h
  end

  def url
    @url ||= begin
      case route
      when  /^https?\:\/\// then route
      else File.join(self.class.base_url, route)
      end
    end
  end

  # Décomposition de la route lorsqu'elle est transmise
  # pour l'identification
  #
  # Les données objet, objet_id, method et context de la route
  # courante. Permet de faire certaines opérations sur les urls vraiment
  # appelées suivant DATA_ROUTES
  attr_reader :context, :objet, :objet_id, :method
  def decompose_route
    route_init != nil || return
    @route, @url_anchor = @route_init.split('#')
    @route != nil || return
    reg = /([a-zA-Z_]+)(?:\/([0-9]+))?\/([a-zA-Z_]+)(?:\?in=([a-zA-Z_]+))?/o
    tout, @objet, @objet_id, @method, @context = route.match(reg).to_a
  end

  # La profondeur du lien, de page en page.
  # La première page testée à une profondeur de 0, les
  # pages de ses liens ont une profondeur de 1, les liens
  # de ces pages ont une profondeur de 2, etc.
  #
  # Les pages pouvant être appelées par différentes
  # pages, elles ont différentes profondeurs, d'où
  # une liste pour garder leur profondeur.
  def depths ; @depths ||= Array.new end

  # La première profondeur. Elle sert notamment quand on ne
  # doit aller que jusqu'à une certaine profondeur.
  def depth; @depth ||= depths.first end
  # La plus petite profondeur
  def depth_min; depths.min end
  # La plus grande profondeur
  def depth_max; depths.max end
  # La profondeur moyenne
  def depth_moy
    (depths.inject(:+).to_f / depths.count).round(1)
  end

  # Le nombre d'appels de cette page
  def call_count ; @call_count ||= 0 end
  def call_count= value; @call_count = value end

  # Liste des textes qui ont appelé cette route
  def call_texts  ; @call_texts ||= Array.new end
  def call_texts= val; @call_texts = val end

  # Liste des IDs des instance TestedPage qui ont
  # appelé cette route
  def call_froms  ; @call_froms ||= Array.new end
  def call_froms= val; @call_froms = val end

  # Retourne le nombre d'erreurs rencontrées sur la
  # page (pour le rapport final - mis en méthode pour servir
  # de clé de classement)
  def errors_count
    @errors.count
  end

  # {TestedPage} Page ayant appelé cette page
  #
  # Pour le moment, on s'en sert par exemple pour obtenir le code
  # d'une page ayant défini une route-ancre.
  def referer
    TestedPage[call_froms.last]
  end

  # Status retourné
  #
  # On utilise cette méthode lorsqu'il s'agit d'un site externe
  def html_status
    @html_status ||= begin
      require 'net/http'
      uri = URI(url)
      response = Net::HTTP.get_response(uri)
      response.code.to_i
    end
  end

end
