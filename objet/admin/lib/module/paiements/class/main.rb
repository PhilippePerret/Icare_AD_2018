# encoding: UTF-8
class Admin
class Paiements
class << self

  def output
    c = String.new
    c << form_from_to
    c << (@content||'')
    return c
  end

  # Contenu qui sera affiché après le formulaire
  # On peut l'incrémenter avec `Admin::Paiements.content << "string"`
  def content
    @content ||= String.new
  end

end #/Self
end #/Paiements
end #/Admin
