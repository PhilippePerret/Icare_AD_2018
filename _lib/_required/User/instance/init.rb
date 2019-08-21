# encoding: UTF-8
=begin

Si un dossier ./_objet/user/lib existe, on le charge toujours

=end
class User

  # ---------------------------------------------------------------------
  #   Instance
  # ---------------------------------------------------------------------

  # Incrémentation du nombre de pages visitées si c'est la
  # même session que précédemment
  def incremente_nombre_pages
    if get(:session_id) == app.session.session_id
      app.session['user_nombre_pages'] += 1
    end
  end

  # À l'initialisation de l'user (en fait, au chargement de
  # la page), on enregistre toujours sa dernière connexion.
  #
  # Attention, cela n'a rien à voir (pour le moment) avec le suivi
  # par IP qui enregistre dans la table :hot, connexions_per_ip
  #
  def set_last_connexion
    # On doit toujours avoir une route, car la propriété `route` ne
    # peut pas être nil dans la table.
    rt = site.current_route ? site.current_route.route : 'site/home'
    # On ne doit pas enregistrer la dernière connexion si
    # c'est une déconnexion (sinon ça pose problème si l'user
    # a choisi de rejoindre sa dernière page consultée après
    # son login)
    return if rt.to_s =~ /logout$/
    dbtable_connexions.set(self.id, {id: self.id, route: rt, time: Time.now.to_i})
  end

  # Retourne la date de dernière connexion de l'user, ou NIL
  # Note : pour le moment, la route ne sert à rien.
  def last_connexion
    @last_connexion ||= begin
      rs = dbtable_connexions.get(self.id)
      rs.nil? ? nil : rs[:time]
    end
  end

end
