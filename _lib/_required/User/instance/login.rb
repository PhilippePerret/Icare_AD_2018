# encoding: UTF-8
=begin

  Module contenant toutes les méthodes de login et déconnexion

=end
class User

  # Méthode qui permet d'auto-identifier l'user. Cette méthode
  # est utile pour identifier automatiquement les users avant
  # de les diriger vers une page définie par args[:route]
  #
  # +args+  {Hash} des arguments transmis à la méthode
  #     :route      La route vers laquelle rediriger l'user après
  #                 l'avoir identifié.
  #
  def autologin args = nil
    args ||= Hash.new
    proceed_login
    args[:route].nil? || redirect_to( args[:route] )
  end

  # Méthode qui procède au login des informations de
  # l'user qui vient de s'identifier.
  # Cette méthode est utilisée par la méthode `login`
  # ci-dessous
  # La méthode a été "isolée" pour pouvoir être utilisée
  # lors d'une reconnexion par des scripts, comme après
  # l'exécution des tests.
  # Elle est également utilisée par la méthode `autologin`
  # ci-dessus qui permet notamment de s'autoidentifier à
  # l'aide d'un ticket.
  #
  def proceed_login
    app.benchmark('-> User#proceed_login')
    app.session['user_id'] = id
    # On met l'utilisateur en utilisateur courant
    User.current= self
    # reset_user_current
    # Variable session permettant de savoir combien de pages a
    # déjà visité l'utilisateur (pour baisser l'opacité des
    # éléments annexes de l'interface)
    app.session['user_nombre_pages'] = 1
    set(session_id: app.session.session_id)
    app.benchmark('<- User#proceed_login')
  end

  # On connecte l'user et on le redirige vers la
  # direction demandée ou logique.
  def login
    app.benchmark('-> User#login')

    # Si le mail n'est pas confirmé
    if false === mail_confirmed? && created_at < Time.now.to_i - 1.hour
      error "Désolé #{pseudo}, mais vous ne pouvez pas vous reconnecter avant d’avoir" +
            ' confirmé votre adresse-mail.' +
            '<br><br>Cette confirmation se fait grâce à un lien contenu dans le message' +
            ' qui vous a été transmis par mail après votre inscription. Merci de' +
            ' vérifier votre boite aux lettres virtuelle.' +
            '<br><br>Vous n’avez plus ce message ?… Pas de problème :' +
            '<br><a href="user/new_mail_confirmation">Renvoyer un message de confirmation</a>.'
      redirect_to 'user/logout'
      return # Pour ne pas enregistrer de message de bienvenue
    end

    proceed_login

    flash 'Bienvenue, %s !' % pseudo

    if param(:login) && param(:login)[:back_to].nil_if_empty
      # Une redirection est demandée
      redirect_to param(:login)[:back_to]
    else
      # Sinon, une redirection est peut-être définie
      # par défaut par les préférences ou l'application
      redirect_after_login
    end
    app.benchmark('<- User#login')
    return true
  end

  # On déconnecte l'user
  def deconnexion
    app.benchmark('-> User#deconnexion')
    app.session['pseudo'] = pseudo # Pour s'en souvenir dans le message
    User.current= nil
    app.session['user_id'] = nil
    set(session_id: nil)
    # Dans le cas où ce serait l'administrateur qui visite en ayant
    # pris l'identité d'un icarien.
    # Noter qu'il faut le faire après avoir tout initialisé ici.
    app.stop_visit_as
    app.benchmark('<- User#deconnexion')
  end

end #/User
