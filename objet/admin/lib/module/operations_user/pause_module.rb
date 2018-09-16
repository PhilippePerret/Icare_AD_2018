# encoding: UTF-8
=begin

  Pour interrompre un module d'apprentissage.

=end
class Admin
class Users
class << self

  # Mise en pause d'un module d'apprentissage
  #
  # La mise en pause consiste à mettre le premier bit des
  # options de l'icmodule à 2 (le remettre à 1 quand on redémarre)
  #
  def exec_pause_module
    icarien.icmodule || begin
      error "L'icarien#{icarien.f_ne} #{icarien.pseudo} n’a pas de module courant…"
      return false
    end

    # Faut-il ou non informer l'icarien que son module a été mise en pause ?
    inform_icarien = !(short_value.to_s.upcase == 'X')

    imodule = icarien.icmodule

    imodule.start_pause
    @suivi << '- Ajout d’une pause au module'
    @suivi << '- Réglage du bit d’options du module'
    @suivi << "- Mise en pause de l’icarien#{icarien.f_ne}"


    if inform_icarien
      icarien.send_mail(
        subject: 'Mise en pause de votre module d’apprentissage',
        message: <<-HTML
  <p>Bonjour #{icarien.pseudo},</p>
  <p>Je vous informe de la mise en pause du module d’apprentissage que vous suiviez à l’atelier Icare.</p>
        HTML
      )
      @suivi << '- Mail envoyé à l’icarien pour l’informer.'
    else
      @suivi << '- L’icarien n’a pas été informé par mail.'
    end
    flash "Mise en pause du module de #{icarien.pseudo} exécuté avec succès en #{ONLINE ? 'ONLINE' : 'OFFLINE'}."

  end
  # /exec_pause_module
end #/<< self
end #/Users
end #/Admin
