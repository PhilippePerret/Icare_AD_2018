# encoding: UTF-8
=begin

  Module qui doit gérer les connexions au site, pour les mémoriser
  et empêcher les intrusions intempestives.

=end
class SiteHtml

  # = main =
  #
  # Méthode principale qui AJOUTE UNE CONNEXION AU SITE
  #
  # Fonctionnement : La méthode tente d'ajouter l'adresse
  # IP à la première base. Si la base n'existe pas, elle
  # la crée. Si la base est occupée, elle ajoute l'adresse
  # dans la deuxième base ou la troisième et les crée si
  # nécessaire.
  def add_connexion ip
    # Ne pas enregistrer le cron job qui se connecte au site
    return if defined?(CRONJOB) && CRONJOB
    # Ne pas enregistrer les commandes SSH qui viennent de
    # l'administration (pour les tests online)
    ip != '87.98.168.93' || return
    # Dans tous les autres cas, on enregistre la connexion
    site.dbm_table(:hot, 'connexions_per_ip').insert(
      ip:     ip || 'TEST', # ip nil arrive pendant les tests
      time:   Time.now.to_i,
      route:  self.route.to_str
    )
  end

end #/SiteHtml
