# encoding: UTF-8
=begin

  Module d'envoi du travail sur l'étape

  Ce main.rb est exécuté quand l'user transmet ses documents de travail.

  Le module :
    - met les documents dans un dossier à télécharger
    - crée des instances pour chaque document en indiquant leurs données et
      leur état.
    - envoi un mail à Phil (admin_mail.erb)
    - fait une annonce actualité

=end

# BARRIÈRE - seul l'icarien de l'étape ou un administrateur peut
# passer par ici.
(user.identified? && (user.admin? || user.actif?)) || raise('Vous n’avez en toute logique aucune raison de passer par ici.')

# Le dossier de téléchargement (forcément détruit et reconstruit)
def folder_download
  @folder_download ||= begin
    d = site.folder_tmp+"download/owner-#{owner.id}-send_work-etape-#{icetape.abs_etape.numero}"
    FileUtils.rm_rf d.to_s
    `mkdir -p "#{d}"`
    d
  end
end
def param_work ; @param_work ||= param(:work) end

def data_document(idocument)
  param_work["document#{idocument}".to_sym]
end


class IcModule::IcEtape

  # Méthode pour créer une instance de document pour le fichier
  # transmis.
  #
  # +args+ est un hash qui permet pour le moment de transmettre la
  # note d'estimation de l'user. Elle sera enregistrée en cote actuelle
  # pour le document
  #
  # RETURN L'IDentifiant de l'icdocument créé
  #
  # Pour les arguments, cf. aussi la méthode
  #   IcModule::IcEtape::IcDocument#create
  #
  def init_instance_icdocument sfile, args = nil
    args ||= Hash.new
    estimation = args[:estimate] || args[:estimation]

    # On ne crée le watcher
    args.merge!(watcher_admin_download: true)

    site.require_objet 'ic_document'
    IcModule::IcEtape::IcDocument.require_module 'create'
    new_doc_id = IcModule::IcEtape::IcDocument.create(self, sfile.name, args)

    return new_doc_id
  end

end#/IcModule::IcEtape



begin

  # Avant d'être sûr, on demande de ne pas écraser le watcher
  dont_remove_watcher

  data_upload = {
    nil_if_empty:         true,
    normalize_filename:   true,
    change_name:          true,
    affixe_max_length:    60    # longueur maximale pour l'affixe
  }

  # Pour connaitre les noms originaux des documents et vérifier qu'un même
  # document ne soit pas envoyé deux fois.
  filenames = Array.new

  # Pour mettre les ID des icdocuments instanciés (qui permettront de
  # renseigner la données @documents de l'étape)
  new_icdocuments_ids = Array.new

  # Pour gérer les erreurs et ne pas obliger l'icarien à redonner les
  # documents. La constitution de cette donnée, qui sera mise dans les
  # paramètres avec le même nom, est décrite dans le fichier user_notify.erb
  @send_work_error = get_send_work_error
  # debug "[main] @send_work_error : #{@send_work_error.inspect}"
  # Pour savoir si une erreur de note indéfinie a été rencontrée
  @error_note_undefined = false

  (1..5).each do |idocument|

    # Les données du document dans le formulaire
    dtempfile = data_document(idocument)

    # Si le dtempfile est nil, c'est que le document a déjà été correctement
    # transmis
    if dtempfile.nil?
      if @send_work_error.empty?
        raise 'Merci de ne pas recharger la page après avoir soumis un formulaire.'
      else
        data_icdoc = @send_work_error[idocument]
        if data_icdoc[:ok] # devrait toujours l'être, ici
          # Un document qui a été traité correctement avant
          # Il n'y a rien à faire pour lui, son enregistrement et son
          # watcher ont déjà été enregistrés. Il faut néanmoins le mettre
          # dans les listes pour qu'il soit enregistré avec l'étape.
          icdoc_id = data_icdoc[:id]
          new_icdocuments_ids << icdoc_id
          next
        else
          raise "Problème systémique. Le document ##{idocument} devrait être OK…"
        end
      end
    end

    estimation  = dtempfile[:estimation].to_i

    # Cas d'un document dont il ne faut que préciser la note d'estimation
    # mais qui a déjà été enregistré au cours précédant.
    @send_work_error.empty? || begin
      data_icdoc = @send_work_error[idocument]
      if data_icdoc && data_icdoc[:note_undefined]
        # Soit la note est maintenant définie et on l'enregistre avant de
        # passer à la suite, soit on rediffuse l'erreur de la note
        # manquante
        if estimation > 0
          icdoc_id = dtempfile[:icdocument_id].to_i
          dbtable_icdocuments.update(icdoc_id, {cote_original: (estimation.to_f/10)})
          @send_work_error[idocument].merge!(note_undefined: false, ok: true)
        else
          @error_note_undefined = true
        end
        # On met l'id de cet ic-document dans la liste car la liste des
        # documents de l'ic-étape sera modifié en fin de processus.
        # On pourrait se dire qu'il n'y a pas besoin de l'actualiser, mais il
        # faut imaginer le cas où un icarien, suite à un oublier d'attribution
        # de note, attribue cette note mais ajouute également un document à
        # son envoi.
        new_icdocuments_ids << icdoc_id
        next # pour ne pas l'enregistrer à nouveau, dans tous les cas
      end
    end

    tempfile    = dtempfile[:file]

    tempfile.size > 0 || next

    # Fichier déjà transmis ? Si oui, on s'en retourne, si non,
    # on l'enregistre.
    false == filenames.include?(tempfile.original_filename) || begin
      error "Merci de ne pas soumettre le même document deux fois (#{tempfile.original_filename}). ;-)"
      next
    end
    filenames << tempfile.original_filename

    # Un SuperFile pour mettre le document fourni (if any). Son nom
    # sera remplacé par le nom du document normalisé
    sfile = (folder_download+'marion_bigoudi')

    # ===================================
    #         UPLOAD DU DOCUMENT
    # ===================================
    # On uploade le document dans le dossier de téléchargement (qui porte le
    # nom "user-<id user>-send_work" -- cf. ci-dessus)
    res = sfile.upload(tempfile, data_upload)
    # Si aucun document n'avait été fourni, on ne fait rien de plus, mais
    # on continue dans le cas, par exemple où le 2e champ n'a pas été utilité
    # mais le troisième ou 4e si.
    res != nil || next

    # Si le nom a dû être changé car trop long
    if sfile.errors && sfile.errors.include?(:affixe_reached_max_length)
      error "Un nom de fichier était trop long, je l'ai raccourci à 60 caractères."
    end

    @send_work_error.merge!(
      idocument => {
        id: nil, name: sfile.name, note_undefined: false, ok: true
      }
    )

    estimation > 0 || begin
      @error_note_undefined = true
      @send_work_error[idocument][:note_undefined]  = true
      @send_work_error[idocument][:ok]              = false
    end

    # = Il faut créer une instance IcDocument pour ce document =
    new_doc_id = icetape.init_instance_icdocument(sfile, {estimate: estimation, no_annonce: true})
    @send_work_error[idocument][:id] = new_doc_id
    new_icdocuments_ids << new_doc_id

  end
  # / Fin de boucle sur les 5 documents

  # Nombre de documents
  nombre_work_documents = new_icdocuments_ids.count

  nombre_work_documents > 0 || raise('Vous n’avez transmis aucun document…')

  # Si une erreur de note non définie a été rencontrée
  if @error_note_undefined
    raise 'Merci d’attribuer une note estimative à vos documents (NB : cette note ne peut pas être égale à zéro).' +
          '<br>ATTENTION ! VOS DOCUMENTS NE POURRONT PAS ÊTRE ENREGISTRÉS SANS CES NOTES !'
  else

    # === QUAND TOUT S'EST BIEN PASSÉ ===

    # Watcher pour changer l'étape de l'icarien
    owner.add_watcher(
      objet:      'ic_module',
      objet_id:   owner.icmodule.id,
      processus:  'change_etape'
    )

    # Une tache pour l'administrateur
    site.dbm_table(:hot, 'taches').insert(
      tache:      "Télécharger les documents de #{user.pseudo}",
      echeance:   Time.now.to_i,
      created_at: Time.now.to_i,
      updated_at: Time.now.to_i
    ) rescue nil

    # La date de remise des commentaires attendus, à mettre
    # dans l'étape, et qu'on relève dans le premier document
    # envoyé. Au pire, en cas de soucis, on la met dans quatre
    # jours
    expected_comments =
      begin
        IcModule::IcEtape::IcDocument.new(new_icdocuments_ids.first).expected_comments
      rescue
        Time.now.to_i + 4.days
      end

    # On renseigne la propriété @documents de l'icetape
    # + on change son statut
    # + on définit la date expected_comments indiquant la date de
    #   remise des documents.
    icetape.set(
      documents:          new_icdocuments_ids.join(' '),
      expected_comments:  expected_comments,
      status:             2
      )
    app.session['send_work_error'] = nil

    # On fait l'annonce
    annonce = "<strong>#{owner.pseudo}</strong> envoie son travail pour l’#{icetape.designation}."
    site.require_objet 'actualite'
    SiteHtml::Actualite.create(user_id: owner.id, message: annonce)

    # Si tout s'est bien passé, on peut demander à effacer le watcher
    do_remove_watcher
  end

  amorce =
    if nombre_work_documents == 1
      'votre document a été enregistré'
    else
      "vos #{nombre_work_documents} documents ont été enregistrés"
    end
  flash "Merci #{owner.pseudo}, #{amorce} et transmis."

rescue Exception => e
  dont_remove_watcher
  debug e
  debug "@send_work_error à la fin : #{@send_work_error.inspect}"
  app.session['send_work_error'] = @send_work_error.to_json
  raise e
ensure
  redirect_to :last_page
end
