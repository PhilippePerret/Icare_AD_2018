# encoding: UTF-8
=begin

  Module permettant de sauver les préférences de l'user

=end
class User
  def save_preferences
    # Enregistrement des préférences de l'utilisateur
    #
    # Noter que pour les checkbox, il faut absolument en lister
    # les clés ci-dessous pour que les changements soient pris en
    # compte. Dans le cas contraire, si une checkbox a été
    # préalablement cochée, sa valeur sera à 'on' mais ne sera
    # pas modifiée si la case est décochée puisqu'elle n'apparaitra
    # pas dans la table prefs ci-dessous.
    #
    # On produit une erreur si l'user qui passe par ici n'est pas
    # l'user possesseur des préférences ou un administrateur
    raise_unless (user.id == site.current_route.objet_id) || user.admin?

    prefs = param(:prefs)

    # --- Choix pour le mail d'actualité --- #
    new_options = self.options
    new_options = new_options.set_bit(17, prefs[:mail_updates])

    # --- Redirection après le bureau --- #
    # Cf. la propriété `site.redirections_after_login` définie
    # dans ./objet/site/config.rb 
    new_options = new_options.set_bit(18, prefs[:goto_after_login])

    # --- Contact ---
    new_options = new_options.set_bit(19, prefs[:type_contact])
    # --- Contact avec le monde ---
    new_options = new_options.set_bit(23, prefs[:type_contact_world])

    # On enregistre les options choisies
    self.set(options: new_options)

    # user.set_preferences prefs
    flash "#{user.pseudo}, vos préférences sont enregistrées."

  end
end
