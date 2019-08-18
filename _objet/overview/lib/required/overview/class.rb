# encoding: UTF-8
class Atelier
class Overview
class << self

  include MethodesMainObjet

  def titre
    'Présentation d’Icare'
  end

  # La section courante, en fonction de la route (= méthode symbolisée)
  def current_section
    @current_section ||= site.current_route.method.to_sym
  end

  def data_onglets
    {}
  end

end #/<< self
end #/Overview
end #/Atelier
