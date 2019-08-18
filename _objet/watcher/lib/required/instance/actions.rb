# encoding: UTF-8
class SiteHtml
class Watcher

  # = main =
  #
  # Méthode principale appelée quand on run le watcher
  # Pour alléger, tout est consigné dans un module à charger.
  #
  # Mais avant de jouer ce watcher, on s'assure qu'il existe bien. Dans le
  # cas contraire, soit c'est un watcher qu'on essaie de forcer soit c'est
  # un rechargement de page.
  def run
    if exist?
      self.class.require_module 'running'
      _run
    else
      error 'Vous demandez une action inconnue. Peut-être venez-vous de recharger la page ? Il ne faut jamais le faire, après la soumission d’un formulaire.'
    end
  end

  # Destruction du watcher
  def remove
    table.delete(id)
  end
end #/Watcher
end #/SiteHtml
