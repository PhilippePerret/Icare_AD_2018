# encoding: UTF-8
=begin

  Méthodes pour instancier un nouveau user jusqu'à après son
  envoi de documents pour son étape de travail

=end
class Simulate

  # La donnée particulière à cette étape est :
  #   :documents
  #   C'est un Array dont chaque élément est un document qui définit :
  #   :file   Le chemin d'accès, :note  La note estimative attribuée
  #
  # Les deux derniers WATCHERS placés dans Simulate#watchers sont
  # les deux watchers pour télécharger les documents (processus: 'admin_download')
  # (ce sont les Hash de données de ces deux watchers)
  #
  def after_send_work args

    start_time = Time.now.to_i - 1

    args[:etape] ||= 1

    test_procedure = args[:test] || args.delete(:test_only_first)
    numero_etape = args[:etape]

    args.key?(:documents) || (raise 'Il faut définir la donnée `documents` pour créer un user après envoi de documents.')
    args[:documents].instance_of?(Array) || (raise 'La donnée documents doit être un Array.')
    documents = args.delete :documents

    # On commence par construire l'user jusqu'au moment où il
    # doit remettre son travail
    after_start_module args

    data_upload = {
      nil_if_empty:         true,
      normalize_filename:   true,
      change_name:          true,
      affixe_max_length:    60    # longueur maximale pour l'affixe
    }

    # Dossier de téléchargement
    folder_download = site.folder_tmp+"download/owner-#{self.user_id}-send_work-etape-#{numero_etape}"
    folder_download.remove if folder_download.exist?

    now = Time.now.to_i

    # On simule la remise du travail pour chaque document

    # Pour mettre les ID des documents, qui seront enregistrés dans
    # l'étape
    new_icdocuments_ids = Array.new

    documents.each do |data_doc|
      fpath = SuperFile.new(data_doc[:file])
      fname = File.basename(fpath)
      fnote = data_doc[:note]

      fname   = fname.as_normalized_filename
      faffixe = File.basename(fname, File.extname(fname))

      # On crée le fichier dans le dossier temporaire
      fdest = folder_download + fname
      fdest.write(fpath.read)

      # On crée un enregistrement pour le document
      data_doc = {
        user_id:            self.user_id,
        abs_module_id:      self.user.icmodule.abs_module_id,
        abs_etape_id:       self.user.icetape.abs_etape_id,
        icmodule_id:        self.user.icmodule.id,
        icetape_id:         self.user.icetape.id,
        original_name:      fname,
        doc_affixe:         faffixe,
        cote_original:      fnote.to_f/10,
        time_original:      now,
        expected_comments:  now+6.days,
        options:            '1',
        created_at:         now,
        updated_at:         now
      }
      new_doc_id = dbtable_icdocuments.insert(data_doc)
      new_icdocuments_ids << new_doc_id
      # On crée un watcher de download du document
      data_watcher = {objet: 'ic_document', objet_id: new_doc_id, processus: 'admin_download'}
      wid = self.user.add_watcher(data_watcher)
      @watchers << data_watcher.merge(id: wid)

      if test_procedure
        expect(fdest).to be_exist
        expect(self.user).to have_watcher data_watcher
        expect(dbtable_icdocuments.get(new_doc_id)).not_to eq nil
      end

    end
    #/Fin boucle sur les documents

    # Il faut régler les données de l'étape
    self.user.icetape.set(
      documents:  new_icdocuments_ids.join(' '),
      status:     2
    )

    # IL faut détruire le watcher qui permettait d'envoyer le
    # travail
    hw = dbtable_watchers.select(where:{user_id: self.user_id, processus: 'send_work', objet: 'ic_etape'}, colonnes: []).first
    dbtable_watchers.delete(hw[:id])

    # Il faut créer un watcher de changement d'étape
    # Note : pour ne pas déstabiliser les @watchers récupérés dans les
    # tests suivants, on ne l'enregistre pas. On pourra le retrouver
    # facilement à l'aide du processus 'change_etape'
    self.user.add_watcher(objet: 'ic_module', objet_id: self.user.icmodule.id, processus: 'change_etape')

    # Nouvelle actualité
    message = "<strong>#{self.user.pseudo}</strong> envoie son travail pour l’étape #{numero_etape} du module “#{self.user.icmodule.abs_module.name}”."
    site.require_objet 'actualite'
    SiteHtml::Actualite.create(message:message, user_id: self.user_id)

    if test_procedure
      expect(self.user.icetape.status).to eq 2
      success 'Le statut de l’étape a été passé à 2'
      expect(dbtable_watchers.count(where:{id: hw[:id]})).to eq 0
      success 'Le watcher d’envoi des documents a été détruit'
      drequest = "created_at > #{start_time} AND user_id = #{self.user_id} AND message = \"#{message}\""
      nb = dbtable_actualites.count(drequest)
      if nb != 1
        puts "# ERREUR : #{nb} actualités ont été trouvées correspondant à : #{drequest}"
        if nb == 0
          puts "# ACTUALITÉS ENREGISTRÉES :\n#{dbtable_actualites.select.pretty_inspect}"
        end
      end
      expect(nb).to eq 1
      success 'Une actualité annonce l’envoi des documents.'
    end
  end

end #/Simulate
