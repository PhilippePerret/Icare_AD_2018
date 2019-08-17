class User

  def reset_all

    # Si l'user n'existe pas, il faut le créer
    if self.id.nil? || dbtable_users.get(self.id).nil?
      return
    end

    req = {where: {user_id: self.id}}
    # Détruire tous les watchers
    dbtable_watchers.delete(req)
    # Détruire tous les modules éventuels
    dbtable_icmodules.delete(req)
    # Il faut déruire ses icetapes
    dbtable_icetapes.delete(req)
    # Détruire tous ses documents
    dbtable_icdocuments.delete(req)
    # Détruire tous les paiements
    dbtable_paiements.delete(req)

    # Le rendre inactif en lui retirant son module éventuel
    self.set_inactif

  end

  # Méthode pour mettre user en user inactif
  def set_inactif
    set(
      options: options.set_bit(16, 4),
      icmodule_id: nil
      )
  end

  # Méthode pour mettre un user en icarien actif
  #
  # +args+ {Hash} pouvant contenir
  #   DONNÉES OBLIGATOIRES (et encore…)
  #   --------------------
  #   :module             IDentifiant du module suivi (entier de 1 à xx)
  #   :etape              Numéro de l'étape courante (100 par défaut)
  #   DONNÉES OPTIONNELLES
  #   --------------------
  #   :paiement_required  Si True, le watcher de paiement sera créé,
  #                       en se servant de :since ou de :started_at pour
  #                       définir le triggered du watcher et le next_paiement
  #                       du module.
  #                       On indiquera aussi dans les options de l'user qu'il
  #                       n'est plus un vrai icarien, sauf si le module
  #                       est de type suivi
  #   :next_paiement      On peut définir explicitement la date de prochain
  #                       paiement (même nil)
  #   :since              Nombre de jours depuis le départ
  #   :started_at         {Fixnum} Alternative à :since, en précisant la
  #                       date exacte en secondes.
  #   :etapes             {STRING} Liste des identifiants d'ic-étapes
  #                       déjà accomplies séparés par des espaces.
  #   :etape_started_at   Date de démarrage de l'étape (secondes)
  #                       Par défaut, un jour avant maintenant
  #   :expected_end       Fin attendue de l'histoire
  #                       par défaut, dans 7 jours.
  #   :expected_comments  Date de remise des commentaires
  #                       Par défaut, NIL (si définie, il faut que
  #                       les travaux aient été envoyés)
  #   :documents          {String} représentant une liste de documents
  #                       pour l'étape courante (ids séparés par des espaces)
  #   :etape_status       Statut de l'étape, 0 par défaut
  #   :travail_propre     {String} Le travail propre éventuel de l'étape
  #                       NIL par défaut.
  #   :alessai            {Bool} Mettre à true pour indique que l'icarien
  #                       doit être mis à l'essai. Noter que si un paiement
  #                       est requis pour un module à DD, l'icarien est
  #                       automatiquement mis à l'essai.
  #
  # RETURN Un {Hash} contenant :
  #   :watcher_paiement_id      ID du watcher de paiement créé
  #   :icmodule_id              ID de l'ic-module créé
  #   :icetape_id               ID de l'ic-etape créée
  def set_actif args = nil
    args ||= Hash.new

    verbose = !!args[:verbose]

    opts = self.options
    verbose && puts("Anciennes options : #{opts} (statut : #{bit_state})")
    opts = opts.set_bit(16,2)
    verbose && puts("Nouvelles options : #{opts}")
    set(options: opts)

    # Données défaut pour le module
    args[:module]       ||= 1
    args[:started_at] ||= (Time.now.to_i - (args[:since] || 2).days)
    verbose && puts("Démarré à #{args[:started_at]} (#{args[:started_at].as_human_date(true, true, ' ', 'à')})")
    # Données pour l'étape courante
    args[:etape]  ||= 100
    args[:etape_started_at] ||= Time.now.to_i - 1.day
    args[:expected_end] ||= Time.now.to_i + 7.days

    is_type_suivi = [7, 8].include?(args[:module])

    # ÉPURATION
    # On commence par supprimer tout ce qui concerne l'user dans les
    # tables des modules et des documents
    table_icmodules   .delete(where: {user_id: self.id})
    table_icetapes    .delete(where: {user_id: self.id})
    table_icdocuments .delete(where: {user_id: self.id})
    table_paiements   .delete(where: {user_id: self.id})
    table_watchers    .delete(where: {user_id: self.id})
    table_actualites  .delete(where: {user_id: self.id})

    date_next_paiement =
      if args.key?(:next_paiement) # pour fonctionner si nil
        args[:next_paiement]
      elsif args[:paiement_required]
        args[:started_at] + 1.month
      else nil end

    # Si un paiement est requis et que ce n'est pas un
    # module de type suivi, ou s'il est expressement demandé
    # de faire un icarien à l'essai, on s'assure que son bit 24
    # soit à '0'
    if (args[:paiement_required] && !is_type_suivi) || args[:alessai]
      self.set(options: options.set_bit(24, 0))
    end

    data_module = {
      user_id:        self.id,
      abs_module_id:  args[:module],
      icetape_id:     nil, # sera affecté plus bas
      next_paiement:  date_next_paiement,
      paiements:      nil,
      started_at:     args[:started_at],
      options:        "0000000000000000",
      pauses:         nil,
      icetapes:       args[:etapes],
      updated_at:     Time.now.to_i
    }
    icmodule_id = table_icmodules.insert(data_module)
    verbose && puts("ID de l'ic-module de #{self.pseudo} : #{icmodule_id}")

    # On affecte ce module à l'icarien
    set(icmodule_id: icmodule_id)

    # ---------------------------------------------------------------------
    #   Création de l'étape
    # ---------------------------------------------------------------------
    # Il faut trouver l'id absolu de l'étape en fonction du module
    # et du numéro d'étape
    hetape = site.dbm_table(:modules, 'absetapes').get(
      where: {module_id: args[:module], numero: args[:etape]}
      )
    hetape != nil || raise("Impossible de trouver l'étape #{args[:etape]} du module #{args[:module]}.")
    abs_etape_id = hetape[:id]
    verbose && puts("ID absolu de l'étape absolue : #{abs_etape_id}")
    data_etape = {
      user_id:            self.id,
      abs_etape_id:       abs_etape_id,
      icmodule_id:        icmodule_id,
      numero:             args[:etape],
      started_at:         args[:etape_started_at],
      expected_end:       args[:expected_end],
      expected_comments:  args[:expected_comments],
      documents:          args[:documents],
      status:             args[:etape_status] || 1,
      travail_propre:     args[:travail_propre]
    }
    icetape_id = table_icetapes.insert(data_etape)
    verbose && puts("ID de l'ic-étape de #{pseudo} : #{icetape_id}")

    # Affecter cette étape au module de l'icarien
    table_icmodules.update(icmodule_id, {icetape_id: icetape_id})

    # Un watcher pour envoyer le travail
    self.add_watcher(
      objet:  'ic_etape', objet_id: icetape_id,
      processus:  'send_work'
    )
    # Un watcher de paiement si nécessaire
    watcher_paiement_id =
      if date_next_paiement
        self.add_watcher(
          objet:      'ic_module',
          objet_id:   icmodule_id,
          processus:  'paiement',
          triggered:  date_next_paiement - 3.days
        )
      else
        nil
      end

    return {
      icmodule_id:          icmodule_id,
      icetape_id:           icetape_id,
      watcher_paiement_id:  watcher_paiement_id
    }
  end
  # /set_actif
end
