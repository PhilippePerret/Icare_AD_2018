# encoding: UTF-8
class User

  # Pour envoyer un message à l'user
  def send_mail data_mail
    site.send_mail( data_mail.merge(to: self.mail) )
  end

  # Détruit l'user
  # --------------
  # S'il y a une procédure propre à l'application, il faut la définir
  # dans `User#app_remove` qui sera appelé avant la destruction de l'user
  # dans la table général des users.
  #
  # Noter que ça ne détruit pas vraiment les données, mais que ça
  # marque simplement l'user détruit (4e bit des options)
  def remove
    self.app_remove if self.respond_to?( :app_remove )
    set_option(:destroyed, 1)
  end

end
