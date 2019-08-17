# encoding: UTF-8
class Simulate

  # Pour les arguments de args, voir la méthode précédente,
  # qui définit tout ce qu'il faut définir pour cette méthode qui ne fait
  # que supprimer des watchers et régler des valeurs.
  def after_user_download_comments args

    start_time = Time.now.to_i - 1
    test_procedure = args[:test] || args.delete(:test_only_first)
    hdocuments = args[:documents]
    hdocuments != nil || (raise 'Il faut impérativement définir la donnée des documents.')
    args[:etape] ||= 1
    etape = args[:etape].freeze

    # === ON REPART DE L'ÉTAPE PRÉCÉDENTE ===
    after_upload_comments args
    # ===========================

    # Supprimer tous les watchers de documents
    dbtable_watchers.delete(where: {user_id: self.user_id, processus: 'user_download_comments'})

    # Les données de documents dans la base
    hdocs = dbtable_icdocuments.select(where: {user_id: self.user_id}, colonnes: [:options, :original_name])

    idoc = nil # pour s'en servir plus bas
    hdocs.each do |hdoc|
      doc_id = hdoc[:id]
      idoc = IcModule::IcEtape::IcDocument.new(doc_id)
      # Ajout du watcher pour déposer le document sur le QDD
      wid = self.user.add_watcher(objet:'ic_document', objet_id: doc_id, processus: 'depot_qdd')
      @watchers << dbtable_watchers.get(wid)
      # Modifier les données des documents
      if hdoc[:options][5].to_i == 0
        # <= Pour les documents qui ont été commentés
        idoc.set(options: idoc.options.set_bit(10,1))
      else
        # <= Pour les document non commentés

      end
    end
    #/ fin de boucle sur les deux documents

    # Modifier le statut de l'étape courante
    idoc.icetape.set(status: 5)

  end

end #/Simulate
