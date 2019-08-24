# encoding: UTF-8
=begin

CLASSE Link
===========

  Link.to(<id lien>[, texte lien][, attributes])

  attributes[:full_url] => on retourne le lien complet, par exemple pour un
  mail.

# Si un lien est ajouté, il faut l'ajouter aussi à la section
# liens de l'aide : ./_lib/console/app/help_app.yml

CLASSE Lien
===========
Rappel : c'est un singleton, on appelle les méthodes par :

    lien.<nom méthode>[ <args>]

=end
DATA_LINKS = {
  G2LN: {
      text:   "Grand Livre des Lois de la Narration",
      href:   'http://www.scenariopole.fr/download/LOIS_NARRATION_PhilPERRET.pdf',
      target: '_blank',
      title:  '“Grand Livre des Lois de la Narration” en version PDF',
      type:   'externe'
  },
  narration: {
      text:   "la collection Narration",
      href:   "http://www.scenariopole.fr/narration",
      target: :new,
      title:  "La collection Narration en version numérique",
      type:   'externe'
  },
  boa: {
      text:   "Boite à Outils de l'Auteur",
      href:   "http://www.laboiteaoutilsdelauteur.fr",
      target: :new,
      title:  "La boite à outils de l'auteur",
      type:   'externe'
  },
  scenariopole: {
      text:   "Scénariopole",
      href:   "http://www.scenariopole.fr",
      target:  :new,
      title:  "Scénariopole, le site du scénario",
      type:   'externe'
  },
  bureau: {
      text:   "votre bureau",
      href:   "bureau/home",
      target: nil,
      title:  "Votre bureau de travail sur l'atelier icare",
      type:   'interne'
  }

}

class Link
  # Pour créer un lien de type `Lien.to(<id lien>)`
  def self.to link_id, text = nil, attrs = nil
    if text.is_a?(Hash)
      attrs = text
      text  = nil
    end
    link = Link.new(link_id)
    link.a(text, attrs)
  end

  attr_reader :id, :data, :attrs
  def initialize link_id
    @id   = link_id
    @data = DATA_LINKS[link_id]
  end
  def a cust_text = nil, attrs = nil
    @attrs = attrs || {}
    @attrs.merge!(text: cust_text) unless cust_text.nil?
    text.in_a(full_attributes)
  end
  def full_attributes
    attrs.merge!(target:  target)
    attrs.merge!(title:   title)
    attrs.merge!(href:    href)
    return attrs
  end
  def text    ; @text   ||= defOrAttr(:text)    end
  def target  ; @target ||= defOrAttr(:target)  end
  def title   ; @title  ||= defOrAttr(:title)   end
  def href
    @href ||= begin
      ref = data[:href]
      if interne? && full_url?
        ref = "http://#{site.distant_host}/#{ref}"
      end
      ref
    end
  end

  def interne?
    data[:interne] === true
  end
  def full_url
    attrs[:full_url] === true
  end

  def defOrAttr(prop)
    attrs[prop] || data[prop]
  end

end

class Lien

  def narration(attrs = nil)
    Link.to(:narration, attrs)
  end

  def bureau titre = nil, attrs = nil
    Link.to(:bureau, titre, attrs)
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
end

def lien_contact titre = nil, options = nil
  lien.contact titre, options
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
