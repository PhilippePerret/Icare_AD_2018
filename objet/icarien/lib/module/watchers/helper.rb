# encoding: UTF-8
=begin

  Méthodes d'helper pour la class `Watchers`
  Note : cette classe gère un ensemble de watchers, elle n'est pas à confondre
  avec la classe singulier Watcher qui gère un watcher

=end
class Watchers
  def as_ul options = nil
    options ||= Hash.new
    list.collect do |watcher|
      watcher.as_li
    end.join('').in_ul(class: options[:class])
  end
end #/Watchers
