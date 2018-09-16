# encoding: UTF-8
class Simulate

  def after_admin_download args
    site.require_objet 'ic_document'

    start_time = Time.now.to_i - 1

    test_procedure = args[:test] || args.delete(:test_only_first)

    # === Jusqu'à l'envoi des documents par l'icarien ===
    after_send_work args
    # ==================== #

    icetape = self.user.icetape

    # Les identifiants des deux documents
    docs_ids = icetape.documents.split(' ').collect{|did|did.to_i}

    # Destruction du watcher pour downloader par l'admin
    docs_ids.each do |doc_id|

      # Destruction du watcher d'admin-download
      dbtable_watchers.delete(where: {user_id: self.user_id, objet: 'ic_document', objet_id: doc_id, processus: 'admin_download'})

      # Création du watcher d'upload-comments
      wid = self.user.add_watcher(objet: 'ic_document', objet_id: doc_id, processus: 'upload_comments')
      @watchers << dbtable_watchers.get(wid)

      # Il faut faire passer le 3e bit des options de chaque document à
      # 1 au lieu de 0
      icdoc = IcModule::IcEtape::IcDocument.new(doc_id)
      icdoc.set(options: icdoc.options.set_bit(2,1))
    end

    # Changement de statut de l'étape
    icetape.set(status: 3)

    if test_procedure
      expect(icetape.status).to eq 3

      docs_ids.each do |doc_id|
        # On ne doit plus trouver le watcher admin_download
        # MAIS on doit trouver le watcher upload_comments
        drequest = {where: {user_id: self.user_id, objet: 'ic_document', objet_id: doc_id, processus: 'admin_download'}}
        expect(dbtable_watchers.count(drequest)).to eq 0
        drequest[:where].merge!(processus: 'upload_comments')
        expect(dbtable_watchers.count(drequest)).to eq 1
        hdoc = dbtable_icdocuments.get(doc_id)
        expect(hdoc[:options][2].to_i).to eq 1
      end
    end

  end
end #/Simulate
