# encoding: UTF-8
=begin

  Pour interrompre un module d'apprentissage.

=end
class Admin
class Users
class << self

  # Arrêt du module d'apprentissage
  def exec_arret_module

    icarien.icmodule || begin
      error "L'icarien#{icarien.f_ne} #{icarien.pseudo} n’a pas de module courant…"
      return false
    end

    data_icarien  = Hash.new
    data_icmodule = Hash.new

    @suivi << '- Mise à NIL de l’icmodule_id de l’icarien.'
    data_icarien.merge!(icmodule_id: nil)

    @suivi << '- Réglage du bit option de l’icarien (inactif)'
    data_icarien.merge!(options: icarien.options.set_bit(16,4))

    @suivi << '- Suppression de son accès libre à la boite à outils (TODO)'
    # TODO On change son état dans la table du BOA

    @suivi << '- Enregistrement de la date d’arrêt du module'
    data_icmodule.merge!(ended_at: Time.now.to_i)

    @suivi << '- Suppression de la date de prochain paiement'
    data_icmodule.merge!(next_paiement: nil)

    @suivi << '- Réglage du bit indiquant que le module est achevé'
    # Rappel : 3: arrêt normal, 4: abandon
    # La différence se fait au niveau du numéro de dernière étape
    # si 990, c'est une fin normale, sinon, c'est un abandon
    etape_fin   = icarien.icetape.abs_etape.numero
    fin_normale = etape_fin == 990
    opts = icarien.icmodule.options.set_bit(0, fin_normale ? 3 : 4)
    fin_normale || @suivi << "  = C’est un abandon de module (étape de fin = #{etape_fin}, donc ≠ de 990)"

    # Changement des données de l'icmodule
    icarien.icmodule.set(data_icmodule)
    # Changement des données de l'icarien
    icarien.set(data_icarien)

    if long_value != nil
      icarien.send_mail(
        subject: 'Fin de votre module d’apprentissage',
        message: <<-HTML
<p>Bonjour #{icarien.pseudo},</p>
<p>Je vous informe de l'arrêt du module d’apprentissage que vous suiviez à l’atelier Icare.</p>
#{long_value}
        HTML
      )
      @suivi << '- Mail envoyé à l’icarien avec le message fourni.'
    end

    flash "Arrêt du module de #{icarien.pseudo} exécuté avec succès en #{ONLINE ? 'ONLINE' : 'OFFLINE'}."
  end

end #/<< self
end #/Users
end #/Admin
