# encoding: UTF-8
class Simulate

  # Cf. after_upload_comments.rb pour voir le détail des paramètres de
  # +args+
  #
  # NOTE IMPORTANTE : pour simplifier, on n'a pas déposer les documents
  # pdfs dans le dossier data/qdd. Il faudra le faire individuellement et à
  # la demande si des tests en ont besoin.
  def after_depot_qdd args
    start_time = Time.now.to_i - 1
    test_procedure = args[:test] || args.delete(:test_only_first)
    hdocuments = args[:documents]
    hdocuments != nil || (raise 'Il faut impérativement définir la donnée des documents.')
    args[:etape] ||= 1
    etape = args[:etape].freeze

    # === ON REPART DE L'ÉTAPE PRÉCÉDENTE ===
    after_user_download_comments args
    # ========================================

    watchers_hdocs = dbtable_watchers.select(where: {user_id: self.user_id, processus: 'depot_qdd'})
    # Supprimer tous les watchers de documents
    dbtable_watchers.delete(where: {user_id: self.user_id, processus: 'depot_qdd'})

    idoc = nil # on en aura besoin pour définir le statut de l'étape
    watchers_hdocs.each do |hdoc|
      idoc = IcModule::IcEtape::IcDocument.new hdoc[:objet_id]
      # Ajouter un watcher de définition de partage pour chaque document
      wid = self.user.add_watcher(
        objet: 'ic_document', objet_id: idoc.id,
        processus: 'define_partage'
      )
      @watchers << dbtable_watchers.get(wid)
      # Définir les bits en fonction du fait que le document soit
      # commenté ou non
      opts = idoc.options
      opts = opts.set_bit(3,1)
      if idoc.has?(:comments)
        opts = opts.set_bit(11,1)
      end
      idoc.set(options: opts)

    end

    # On passe le statut de l'étape à 6
    # Noter qu'on doit prendre l'étape dans les documents, car l'étape
    # a peut-être changé entre temps
    idoc.icetape.set(status: 6)

    if test_procedure

    end
  end
  # /after_depot_qdd

end #/Simulate
