# encoding: UTF-8

class Atelier
class << self

  # = main =
  #
  # Méthode qui retourne le code HTML pour les statistiques
  # Le document statistique est actualisé une fois par jour ou lorsque
  # le fichier est volontairement détruit.
  def statistiques
    if uptodate?
      site.require_all_in('./objet/site/statistiques/css')
    else
      site.require_all_in('./objet/site/statistiques')
      update_stats_file
    end
    stats_file.read
  end

  def uptodate?
    stats_file.exist?
  end

  def stats_file
    @stats_file ||= site.folder_objet+'site/statistiques/statistiques.html'
  end

end# << self
end #/Atelier
