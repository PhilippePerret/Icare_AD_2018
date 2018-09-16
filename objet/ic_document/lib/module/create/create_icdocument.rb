# encoding: UTF-8
=begin

  Module pour créer une instance document pour l'étape +icetape+

=end
class IcModule
class IcEtape
class IcDocument
class << self

  # = main =
  #
  # Création d'une instance IcDocument
  #
  # +options+
  #   :estimation               La note attribuée au document (ou nil)
  #   :watcher_upload_comments  Si true, on fait le watcher pour commenter
  #                             le document.
  #   :watcher_admin_download   Si true, le watcher pour que l'administrateur
  #                             puisse charger le document.
  #   :no_annonce               Si true, on n'annonce pas le document dans les
  #                             activités.
  #
  # La méthode peut être appelée par un watcher normal ou par
  # la procédure d'injection d'un document.
  #
  def create icetape, document_name, options = nil
    options ||= Hash.new
    owner     = icetape.owner
    icmodule  = icetape.icmodule

    expected_comments = Time.now.to_i +
      if icmodule.abs_module.intensif?
        4
      elsif icmodule.abs_module.suivi_lent?
        8
      else
        6
      end.days

    # Quand c'est un document estimé par l'auteur
    estimation = (options[:estimate] || options[:estimation]).to_i

    now = Time.now.to_i
    data_icdocument = {
      user_id:            owner.id,
      abs_module_id:      icmodule.abs_module_id,
      abs_etape_id:       icetape.abs_etape_id,
      icmodule_id:        icmodule.id,
      icetape_id:         icetape.id,
      doc_affixe:         File.basename(document_name, File.extname(document_name)),
      original_name:      document_name,
      time_original:      now,
      expected_comments:  expected_comments,
      options:            '1',
      cote_original:      (estimation > 0 ? (estimation.to_f/10) : nil),
      created_at:         now,
      updated_at:         now
    }
    # debug "\n\ndata_icdocument : #{data_icdocument.pretty_inspect}"
    new_doc_id = dbtable_icdocuments.insert(data_icdocument)

    # Ajout de l'identifiant du document aux documents de
    # l'étape (il peut y en avoir ou ne pas y en avoir)
    documents_etape = "#{icetape.documents} #{new_doc_id}".strip

    # Avec l'outil d'injection de document envoyé par
    # mail, on doit passer directement au watcher permettant
    # d'uploader les commentaires (:watcher_upload_comments).
    # Sinon, c'est le cas normal où on doit me permettre de
    # télécharger les documents (:watcher_admin_download)
    if options[:watcher_upload_comments]
      owner.add_watcher(
        objet:      'ic_document',
        objet_id:   new_doc_id,
        processus:  'upload_comments'
      )
      statut_etape = 3
    elsif options[:watcher_admin_download]
      owner.add_watcher(
        objet:      'ic_document',
        objet_id:   new_doc_id,
        processus:  'admin_download'
      )
      statut_etape = 2
    end

    # On change les données de l'étape en ajoutant ce
    # nouveau document et en changeant le statut de
    # l'étape concernée.
    icetape.set(
      documents: documents_etape,
      status:   statut_etape
    )

    # Annonce sauf si contre-indication
    # On raccourci le nom du document si nécessaire
    if !options[:no_annonce]
      site.require_objet 'actualite'
      SiteHtml::Actualite.create(
        user_id: owner.id,
        message: "<strong>#{owner.pseudo}</strong> envoie le document « #{bonne_longueur_nom(document_name)} » pour l’#{icetape.designation}."
        )
    end

    return new_doc_id
  end

  # Retourne le nom du document mais avec son affixe réduit
  # pour le message d'actualité de l'accueil.
  def bonne_longueur_nom docname
    docname.length > 24 || ( return docname )
    ext = File.extname(docname)
    "#{File.basename(docname,ext)[0..19]}…#{ext}"
  end

end #/<< self
end #/IcDocument
end #/IcEtape
end #/IcModule
