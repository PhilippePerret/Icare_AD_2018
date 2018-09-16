# encoding: UTF-8
class Simulate

  # Simule tous les échanges depuis l'inscription jusqu'à l'upload des
  # commentaire sur des documents.
  # +args+ doit contenir :
  #
  #   :documents      La liste des documents en jeu.
  #                   Par rapport à la méthode précédente
  #                   (pour after_admin_download) il faut déterminer dans chaque
  #                   hash si le document a été commenté (comments: true) ou
  #                   non (comments: false). Par défaut, un document est
  #                   toujours commenté.
  #
  #   OPTIONNEL
  #     :test         Pour débugger cette méthode en détail
  #     :module       L'ID du module
  #     :sexe         Le sexe 'H' ou 'F' de l'user à créer
  #     :password     Le mot de passe (quand identification nécessaire)
  #
  def after_upload_comments args
    start_time = Time.now.to_i - 1

    test_procedure = args[:test] || args.delete(:test_only_first)
    hdocuments = args[:documents]
    hdocuments != nil || (raise 'Il faut impérativement définir la donnée des documents.')
    args[:etape] ||= 1
    etape = args[:etape].freeze

    # === Jusqu'à l'envoi des documents par l'icarien ===
    after_admin_download args
    # ==================== #

    icetape = self.user.icetape

    # Les identifiants de tous les documents
    docs_ids = icetape.documents.split(' ').collect{|did|did.to_i}

    # Destruction du watcher pour uploader les comments par l'admin
    docs_ids.each_with_index do |doc_id, idoc|

      # Destruction du watcher d'upload comments
      dbtable_watchers.delete(where: {user_id: self.user_id, objet: 'ic_document', objet_id: doc_id, processus: 'upload_comments'})

      # Comportement différent en fonction du fait que le document
      # est commenté ou non.
      hdocument = hdocuments[idoc]

      if hdocument[:comments] === false
        # === DOCUMENT NON COMMENTÉ ===
        # Il faut régler le 5e bit des options (fin de cycle)
        icdoc = IcModule::IcEtape::IcDocument.new(doc_id)
        icdoc.set(options: icdoc.options.set_bit(13,1))
      else
        # === DOCUMENT COMMENTÉ ===
        # Création du watcher d'user_download_comments
        wid = self.user.add_watcher(objet: 'ic_document', objet_id: doc_id, processus: 'user_download_comments')
        @watchers << dbtable_watchers.get(wid)
        # Il faut faire passer le 9e bit des options
        icdoc = IcModule::IcEtape::IcDocument.new(doc_id)
        icdoc.set(options: icdoc.options.set_bit(8,1))
        # IL faut faire le fichier comments dans le dossier des download
        # le dossier des commentaires
        folder_download ||= site.folder_tmp + "download/owner-#{self.user_id}-upload_comments-#{icdoc.icmodule.id}-#{icdoc.icetape.id}"
        fpath = folder_download + "#{hdocument[:affixe]}_comsPhil.odt"
        fsrc  = SuperFile.new 'mon_travail.odt'.in_folder_document
        fpath.write fsrc.read
        if test_procedure
          expect(fpath).to be_exist
        end
      end

    end

    # Changement de statut de l'étape
    icetape.set(status: 4)

    if test_procedure
      expect(icetape.status).to eq 4

    end

  end
end #/Simulate
