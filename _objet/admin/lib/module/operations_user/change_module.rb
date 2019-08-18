# encoding: UTF-8
class Admin
class Users
class << self

  # Mettre à false manuellement, pour le moment, pour
  # simuler la chose ou la passer.
  def simulation ; false end

  def new_absmodule
    @new_absmodule ||= AbsModule.new(new_absmodule_id)
  end
  def old_absmodule
    @old_absmodule ||= AbsModule.new(old_absmodule_id)
  end
  def old_icmodule
    @old_icmodule ||= icarien.icmodule
  end
  def new_absetape
    @new_absetape ||= new_absmodule.etape_by_numero(new_etape_numero)
  end
  def old_icetape
    @old_icetape ||= icarien.icetape
  end

  def old_absmodule_id
    @old_absmodule_id ||= icarien.icmodule.abs_module_id
  end
  def new_absmodule_id
    @new_absmodule_id ||= short_value.to_i
  end
  def new_etape_numero
    @new_etape_numero ||= medium_value.to_i
  end

  # Changement de module de l'icarien
  #
  def exec_change_module
    site.require_objet 'abs_module'
    site.require_objet 'abs_etape'
    site.require_objet 'ic_module'
    site.require_objet 'ic_etape'
    # Pour définir toutes les valeurs courantes
    old_absmodule
    old_icmodule
    old_icetape

    # Vérifier que les valeurs soient bonnes
    right_values? || return
    if simulation
      @suivi << "CETTE OPÉRATION EST UNE SIMPLE SIMULATION SANS EFFET."
    end
    @suivi << "REQUÊTE DEMANDÉE :"
    @suivi << "Changement du module de l'icarien#{icarien.fille? ? 'ne' : ''} #{icarien.pseudo}"
    @suivi << "Passage du module ##{old_absmodule_id} (#{old_absmodule.titre})"
    @suivi << "À l'étape #{new_absetape.numero}, “#{new_absetape.titre}”"
    @suivi << "du module ##{new_absmodule.id} (#{new_absmodule.titre})"
    @suivi << "/REQUÊTE"
    # On crée un nouvel icmodule pour l'icarien avec le
    # module choisi
    new_icmodule_for_icarien
    # Envoyer un mail à l'icarien concerné
    send_mail_to_icarien
    # Message d'actualité annonçant le changement de module
    # de l'icarien
    site.require_objet 'actualite'
    aid = SiteHtml::Actualite.create(
      user_id: icarien.id,
      message: "<strong>#{icarien.pseudo}</strong> passe au module d'apprentissage “#{new_absmodule.titre}”."
    )
    @suivi << "Nouvelle actualité ##{aid.inspect} créée avec succès pour #{icarien.pseudo}."

    # Si tout s'est bien passé jusqu'à présent, on peut
    # faire les suppression requises

    # Arrêter la dernière étape
    mess = "Arrêt de l'ancienne étape #{old_icetape.id} (#{old_icetape.titre}) - son statut est mis à 7"
    if simulation
      mess "[Simulation] #{mess}"
    else
      old_icetape.set(status: 7)
    end
    @suivi << mess

    # Supprimer les watchers concernant l'étape
    mess = "Suppression des watcher de l'ancienne étape"
    if simulation
      mess "[Simulation]"
    else
      wdata = {objet: 'ic_etape', objet_id: old_icetape.id}
      icarien.remove_watcher(wdata)
    end
    @suivi << mess

    # Stopper le précédent module
    # Dans tous les cas, le changement de module
    # correspond à l'arrêt du module précédent
    mess =  "Arrêt du module ##{old_icmodule.id} de #{icarien.pseudo}"
    if simulation
      mess = "[Simulation] #{mess}"
    else
      old_icmodule.stop
    end
    @suivi << mess

    @suivi << "=== OPÉRATION EXÉCUTÉE AVEC SUCCÈS ==="
  end

  # Retourne false si les valeurs fournies sont mauvaises
  def right_values?
    icarien.pseudo       || raise('Il faut choisir l’icarien visé.')
    icm = icarien.icmodule
    icm != nil || begin
      raise "L’icarien#{icarien.femme? ? 'ne' : ''} #{icarien.pseudo} ne possède pas de module d’apprentissage…"
    end
    new_absmodule_id > 0 || raise('L’identifiant du nouveau module doit être supérieur à zéro.')
    new_absmodule.exist? || raise("L’identifiant de module ##{new_absmodule_id} ne correspond à aucun module…")
    # On vérifie que le module ne soit pas justement celui suivi
    # par l'icarien choisi.
    icm.abs_module_id != new_absmodule_id || begin
      raise 'Le module choisi est le même que celui que suit actuellement l’icarien !'
    end
    new_etape_numero > 0 || raise('Le numéro de l’étape doit être un nombre supérieur à zéro.')
    new_absetape != nil  || raise("L'étape numéro ##{new_etape_numero} est inconnu dans le module “#{new_absmodule.titre}”…")
    # Si on arrive ici, tout est bon.
    @suivi << "Toutes les valeurs sont correctes, on peut procéder à l'opération."
    return true
  rescue Exception => e
    error "#{e.message}<br>Impossible de changer son module."
    false
  end


  # On crée le nouveau module d'apprentissage (IcModule)
  # pour l'icarien.
  def new_icmodule_for_icarien
    # Le temps du prochain paiement est celui du prochain
    # paiement du module courant
    # Note : cette valeur peut être nulle
    time_next_paiement = old_icmodule.next_paiement
    @suivi << "Prochain paiement du module courant : #{time_next_paiement.inspect} (#{time_next_paiement.as_date})"

    # Créer le nouvel icmodule pour l'icarien
    if simulation
      @suivi << "[Simulation] Création d'un nouveau icmodule d'absmodule id ##{new_absmodule_id}."
    else
      new_icmodule = IcModule.create_icmodule_for(icarien, new_absmodule_id)
      new_icmodule.instance_of?(IcModule) || raise('Le nouvel IcModule n’a pas pu être créé pour l’icarien…')
      @suivi << "Nouvel icmodule ##{new_icmodule.id} créé avec succès pour #{icarien.pseudo}"
    end

    # Créer l'ic-étape voulu (avec le numéro choisi)
    if simulation
      @suivi << "[Simulation] Création d'une ic-étape pour le nouvel ic-module avec le numéro #{new_etape_numero}."
    else
      new_icetape = IcModule::IcEtape.create_for(new_icmodule, new_etape_numero)
      new_icetape.instance_of?(IcModule::IcEtape) || raise('La nouvelle IcEtape n’a pas pu être créée pour l’icarien…')
      @suivi << "Nouvelle icétape ##{new_icetape.id} créée avec succès pour #{icarien.pseudo}"
    end

    if simulation
      @suivi << "[Simulation] Définition des nouvelles données du nouveau ic-module."
    else
      # Changer les données du nouvel icmodule
      datam = {
        icetape_id:     new_icetape.id,
        options:        new_icmodule.options.set_bit(0, 1),
        next_paiement:  time_next_paiement,
        started_at:     Time.now.to_i
      }
      new_icmodule.set(datam)
      @suivi << "Définition des nouvelles données pour l'icmodule : #{datam.inspect}"
    end

    if simulation
      @suivi << "[Simulation] Création d'un watcher pour remettre les documents."
    else
      # Créer un watcher pour remettre les documents
      wdata = {objet:'ic_etape', objet_id:new_icetape.id, processus:'send_work'}
      watcher_id = icarien.add_watcher(wdata)
      icarien.has_watcher?(wdata) || raise('Le watcher pour la remise des documents n’a pas été trouvé…')
      @suivi << "Nouveau watcher ##{watcher_id} pour la remise des documents de l'étape."
    end

    # Si le module est de type suivi, il faut :
    # Si l'ancien module n'était pas de type suivi
    #   => Créer un watcher de prochain paiement
    # Si l'ancien module était de type suivi
    #   => Détruire ce watcher
    if old_icmodule.type_suivi?
      wdata = { objet: 'ic_module', processus: 'paiement',
                objet_id: old_icmodule.id}
      if simulation
        w = icarien.watcher(wdata)
        @suivi << "[Simulation] Destruction du watcher #{w[:id]} de prochain paiement."
      else
        nombre_de_detruits = icarien.remove_watcher(wdata)
        nombre_de_detruits = 1 || raise('Impossible de détruire l’ancien watcher de paiement…')
        @suivi << "L'ancien watcher de prochain paiement a été détruit."
      end
    else
      @suivi << "L'ancien module n'était pas un module de suivi de prochain, il n'y a donc pas de watcher de prochain paiment."
    end

    if new_absmodule.type_suivi?
      # Créer un watcher pour le prochain paiement
      if simulation
        @suivi << "[Simulation] Création d'un watcher de prochain paiement au #{time_next_paiement.as_date}"
      else
        watcher_id =
          icarien.add_watcher(
            objet:      'ic_module',
            objet_id:   new_icmodule.id,
            processus:  'paiement',
            triggered:  time_next_paiement
          )
        wdata = {objet:'ic_module', processus: 'paiement', objet_id: new_icmodule.id}
        icarien.has_watcher?(wdata) || raise('La création du watcher de prochain paiement a échoué…')
        @suivi << "Nouveau watcher ##{watcher_id} pour le prochain paiement du module."
      end
    else
      @suivi << "Le nouvelle module n'étant pas de type suivi, on ne crée pas de watcher de prochain paiement."
    end

    if simulation
      @suivi << "[Simulation] On met l'icmodule de l'icarien à l'ID du nouveau module."
    else
      icarien.set(icmodule_id: new_icmodule.id)
      @suivi << "Icmodule de l'icarien mis à ##{new_icmodule.id}."
    end
  end

  def send_mail_to_icarien
    data_mail = {
      subject:    'Changement de module d’apprentissage',
      formated:   true,
      message:  <<-EOM
      <p>Bonjour #{icarien.pseudo},</p>
      <p>Je vous informe que Phil vient de changer votre module d'apprentissage.</p>
      <p>Vous suivez à présent le module “#{new_absmodule.titre}” et vous êtes à l'étape ##{new_absetape.numero}, “#{new_absetape.titre}”.</p>
      <p>Bien à vous et bon travail à l'atelier !</p>
      <p>Le Bot de l'atelier Icare</p>
      EOM
    }
    if simulation
      @suivi << "[Simulation] Envoi du mail de données #{data_mail.inspect} à #{icarien.pseudo}."
    else
      icarien.send_mail(data_mail)
    end
  end

end #/<< self
end #/Users
end #/Admin
