# encoding: UTF-8
=begin

  MÉTHODES
  ========

      Atelier.remove_statistiques_file

        Détruire le fichier statistiques pour forcer sa reconstruction

=end
class Atelier
class << self
  # Pour détruire facilement le fichier statistiques lorsqu'une
  # données importante a changé
  def remove_statistiques_file
    sf = (site.folder_objet+'site/statistiques.html')
    sf.remove if sf.exist?
  end

end #<< self
end #/ Atelier
