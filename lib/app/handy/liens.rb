# encoding: UTF-8
=begin

# Si un lien est ajouté, il faut l'ajouter aussi à la section
# liens de l'aide : ./lib/app/console/help_app.yml

Extension de la classe Lien, pour l'application courante

Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
class Lien

  # Lien vers le bureau
  def bureau titre = 'bureau', options = nil
    build "bureau/home", titre, options
  end

  def profil titre = 'profil', options = nil
    build "user/#{user.id}/profil", titre, options
  end

  def modules titre = 'liste des modules d’apprentissage', options = nil
    build 'abs_module/list', titre, options
  end

  def quai_des_docs titre = 'Quai des docs', options = nil
    build "quai_des_docs/home", titre, options
  end

  def narration titre = "la collection Narration", options = nil
    titre.in_a(href: "http://www.scenariopole.fr/narration", target: :new)
  end
end

def link_narration titre = "la collection Narration", options = nil
  lien.narration titre, options
end
alias :lien_narration :link_narration

def url_boa route = nil
  url = 'http://www.laboiteaoutilsdelauteur.fr'
  route.nil? || url += "/#{route}"
  return url
end
alias :route_boa :url_boa

def url_scenariopole route = nil
  url = 'http://www.scenariopole.fr'
  route.nil? || url += "/#{route}"
  return url
end
