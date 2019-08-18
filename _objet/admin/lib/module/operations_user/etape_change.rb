# encoding: UTF-8
class Admin
class Users
class << self

  def exec_etape_change
    icarien.actif? || raise('On ne peut changer l’étape que d’un icarien actif, voyons !')
    if short_value.nil?
      raise 'Il faut définir le numéro de la nouvelle étape.'
    else
      new_etape_numero = short_value
      @suivi << "Nouvelle étape de numéro : #{new_etape_numero}"
      site.require_objet 'ic_etape'
      icmodule = icarien.icmodule

      # Si des watchers existent concernant une étape courante, on doit
      # les supprimer
      ws = dbtable_watchers.select(where: {user_id: icarien.id, objet: 'ic_etape'})
      unless ws.empty?
        dbtable_watchers.delete(where: {user_id: icarien.id, objet: 'ic_etape'})
        @suivi << "Watchers supprimés : #{ws.count}"
      end
      etape_courante = icarien.icetape.id.to_s
      @suivi << "L'étape courante à l'id ##{etape_courante}"

      @suivi << "Étapes courantes du module courant : #{icmodule.icetapes}"
      etapes = (icmodule.icetapes || "").split(' ')
      etapes << etape_courante
      etapes = etapes.uniq.join(' ')

      # On crée l'instance de la nouvelle étape.
      new_icetape = IcModule::IcEtape.create_for icmodule, new_etape_numero
      new_icetape_id = new_icetape.id

      # Juste pour voir, lorsque les deux lignes ci-dessus sont ex-commentées
      # new_icetape_id = 12544

      icmodule.set(
        icetapes:     etapes,
        icetape_id:   new_icetape_id
      )
      @suivi << "Étapes du module mises à : #{etapes}"
      @suivi << "Étape courant du module mise à #{new_icetape_id}"


      # # Ajouter un watcher pour la remise du travail
      data_watcher = {
        objet:      'ic_etape',
        objet_id:   new_icetape_id,
        processus:  'send_work'
      }
      icarien.add_watcher(data_watcher)
      @suivi << "Nouveau watcher pour la remise du travail : #{data_watcher.inspect}"

      # Mail envoyé à l'icarien
      data_mail = {
        subject:    'Changement de votre étape de travail',
        formated:   true,
        message:    <<-HTML
        <p>Bonjour #{icarien.pseudo},</p>
        <p>Un message pour vous avertir que vous avez été passé#{icarien.f_e} à l'étape #{new_etape_numero}.</p>
        <p>Vous trouverez le travail correspondant à cette étape sur votre bureau.</p>
        HTML
      }
      icarien.send_mail(data_mail)
      @suivi << "Mail envoyé à #{icarien.mail} : #{data_mail.inspect}"
      flash "#{icarien.pseudo} a été passé#{icarien.f_e} à l'étape numéro #{new_etape_numero}."
    end
  rescue Exception => e
    debug e
    error e.message
  end
end #/<< self
end #/Users
end #/Admin
