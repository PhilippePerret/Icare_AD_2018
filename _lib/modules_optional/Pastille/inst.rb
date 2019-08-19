# encoding: UTF-8
=begin

  Pour la gestion des pastilles de tâches

=end
class SiteHtml
class Pastille

  # {Integer} Le nombre à afficher dans la pastille
  attr_accessor :nombre

  # Le fond de la pastille, entre 'red', 'blue', 'green'
  attr_accessor :background

  # {Array of String} La liste des tâches sous forme de texte
  attr_accessor :taches

  # Le titre qui doit apparaitre quand on glisse la souris sur la
  # pastille
  attr_accessor :title

  # {String} L'url à atteindre
  attr_accessor :href

  # {StringHTML} Code HTML de la pastille
  def output
    (apastille + bloc_taches).in_div(id: 'div_pastille_taches')
  end

  # Détermine les valeurs de la pastille
  def set data
    data.each { |prop, val| instance_variable_set("@#{prop}", val) }
  end

  # {String} Code HTML de la pastille elle-même, qui est un lien
  # à cliquer
  def apastille
    @apastille ||= begin
      link_data = {
        href: href, class: "pastille_taches",
        style:"background-color:#{background}"
      }
      link_data.merge!(title: title) unless title.nil?
      nombre.to_s.in_a(link_data)
    end
  end

  def bloc_taches
    @bloc_taches ||= begin
      case taches
      when String then taches
      else taches.join('<br>')
      end.in_div(class:'taches')
    end
  end
end #/Pastille
end #/SiteHtml
