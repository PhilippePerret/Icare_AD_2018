# encoding: UTF-8
=begin

  Pour interrompre un module d'apprentissage.

=end
class Admin
class Users
class << self

  # Redémarrage d'un module d'apprentissage
  #
  # NORMALEMENT, c'est l'auteur qui doit le faire, depuis
  # son bureau.
  #
  # Le redémarrage consiste à mettre le premier bit des
  # options de l'icmodule à 1 (il est à 2 quand il est en pause)
  #
  def exec_restart_module

    icarien.icmodule || begin
      error "L'icarien#{icarien.f_ne} #{icarien.pseudo} n’a pas de module courant…"
      return false
    end

    # Le module de l'icarien
    imodule = icarien.icmodule

    if imodule.options[0].to_i != 2
      error "Ce module n'est pas en pause, impossible de le redémarrer."
      return false
    end

    imodule.stop_pause
    @suivi << '- Enregistrement de la pause'
    @suivi << '- Réglage du bit d’options du module'

    icarien.send_mail(
      subject: 'Redémarrage de votre module d’apprentissage',
      message: <<-HTML
  <p>Bonjour #{icarien.pseudo},</p>
  <p>Je vous informe du redémarrage du module d’apprentissage que vous suiviez à l’atelier Icare.</p>
      HTML
    )
    @suivi << '- Mail envoyé à l’icarien pour l’informer.'

    flash "Redémarrage du module d’apprentissage de #{icarien.pseudo} exécuté avec succès en #{ONLINE ? 'ONLINE' : 'OFFLINE'}."

  end
  # /exec_pause_module
end #/<< self
end #/Users
end #/Admin
