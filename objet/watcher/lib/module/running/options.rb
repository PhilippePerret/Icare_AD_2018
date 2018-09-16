# encoding: UTF-8
=begin

  Réglage des options de watcher

=end
class SiteHtml
class Watcher

  # ---------------------------------------------------------------------
  #   Méthodes qu'on peut appeler depuis le main.rb du watcher pour
  #   régler certaines options
  # ---------------------------------------------------------------------

  # Pour ne pas détruire le watcher en fin de processus
  # Pour le moment, ça ne sert que pour les tests.
  def dont_remove_watcher
    @dont_remove_watcher = true
  end
  # Quand on a demandé de ne pas écraser le watcher (avec dont_remove_watcher)
  # on peut redemander à le faire par cette méthode
  def do_remove_watcher
    @dont_remove_watcher = false
  end

  # Pour ne pas envoyer le mail prévu pour l'administrateur
  def no_mail_admin
    @dont_send_mail_admin = true
  end
  # Pour ne pas envoyer le mail prévu pour l'icarien
  def no_mail_user
    @dont_send_mail_user = true
  end

  # ---------------------------------------------------------------------
  #   Méthodes d'état et d'options du watcher
  #   (utilisées par le programme lui-même)
  # ---------------------------------------------------------------------
  def main_file?  ; main_file.exist?  end
  def admin_mail? ; admin_mail.exist? && !@dont_send_mail_admin end
  def user_mail?  ; user_mail.exist?  && !@dont_send_mail_user  end

end #/Watcher
end #/SiteHtml
