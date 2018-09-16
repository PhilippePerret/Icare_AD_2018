# encoding: UTF-8
=begin

  Module permettant de construire des listings à partir du quai
  des docs.

  Il a été mis en module séparé pour pouvoir être utilisé par
  l'affichage du listing des documents d'une étape donné dans le
  bureau d'un icarien

=end
class QuaiDesDocs
class << self

  # +options+
  #   :filtre     Le filtre à appliquer sur la liste des documents
  #               à voir.
  #               Ce filtre peut s'appliquer sur :
  #               :user_id    ID de l'icarien. Si spécifié, seuls les
  #                           documents de cet icarien seront considérés
  #               :module     ID absolu du module d'apprentissage
  #                           Si spécifié, seuls les documents de ce module
  #                           seront considérés
  #               :etape      ID absolu unique de l'étape absolu des
  #                           documents à voir
  #               :created_between
  #                           Array composé de
  #                             [timesecond départ, timesecond fin]
  #   :avertissement  Si True, on ajoute un message en tête de liste
  #                   pour indiquer qu'il faut respecter la confidentialité
  #                   des documents.
  #                   Défault: true
  #   :all            Si true (false par défaut), on considère tous les
  #                   documents, même ceux qui ne sont pas partagés.
  #   :full           Si true, on ajoute au formulaire pour télécharger le
  #                   document un formulaire pour le coter (si l'user courant
  #                   n'est pas l'auteur du document) ou pour en re-définir le
  #                   partage (cf. IcDocument#form_cote_or_partage)
  #   :infos_document Si True, on affiche les informations du document, sur
  #                   son module, ses dates, etc.
  #   :key_sorted     La clé pour le classement des documents. Par défaut,
  #                   c'est l'utilisateur ('user_id ASC') mais on peut mettre tout
  #                   autre propriété qui doit être une colonne, par exemple
  #                   'time_original DESC' ou 'created_at ASC'
  # RETURN
  #   Le code HTML de la liste UL des documents ou NIL dans le cas
  #   où aucun document ne correspondait au filtre. C'est la méthode
  #   appelante qui doit gérer ce cas.
  #
  # NOTES
  #   * Seuls les documents ayant atteint la fin de leur cycle doivent
  #     être pris en considération dans ce listing. Leur statut minimal
  #     doit donc être
  #   * Dans tous les cas, si l'user courant est à l'essai, on indique
  #     sa limite de documents.
  #   * Le nombre de documents trouvés peut s'obtenir par :
  #     QuaiDesDocs.nombre_documents_found
  #
  def as_ul options = nil
    options ||= Hash.new

    # Paramètres de premier niveau
    filtre = options.delete(:filtre) || Hash.new
    options.key?(:avertissement) || options.merge!(avertissement: true)
    with_avertissement  = options.delete(:avertissement)
    even_not_shared     = !!options.delete( :all )
    full_card           = !!options.delete(:full)
    infos_docs          = !!options.delete(:infos_document)
    key_sorted          = options.delete(:key_sorted) || "user_id ASC"

    # ATTENTION : options sera ré-initialisé plus bas

    # --- Construction du filtre ---
    list_request = {
      where: Array.new
    }
    # On doit toujours considérer seulement les documents arrivés
    # en fin de cycle.
    list_request[:where] << "(SUBSTRING(options,6,1) = '1' OR SUBSTRING(options,14,1) = '1')"

    user_id = filtre.delete(:user_id)
    if user_id
      list_request[:where] << "user_id = #{user_id}"
    end

    abs_module_id = filtre.delete(:module)
    abs_etape_id = filtre.delete(:etape)
    # Noter que si l'étape est spécifiée, la recherche du module
    # n'est pas nécessaire puisque l'étape est associée toujours à un
    # module en particulier
    if abs_etape_id
      list_request[:where] << "abs_etape_id = #{abs_etape_id}"
    elsif abs_module_id
      list_request[:where] << "abs_module_id = #{abs_module_id}"
    end

    created_between = filtre.delete(:created_between)
    if created_between
      list_request[:where] << "created_at BETWEEN #{created_between.first} AND #{created_between.last}"
    end

    user_id = filtre.delete(:user_id)
    if user_id
      list_request[:where] << "user_id = #{user_id}"
    end


    list_request[:where] = list_request[:where].join(' AND ')
    list_request.merge!(order: key_sorted)

    # --- Fin de définition du filtre ---

    options = {
      as: options[:as] || :instance
    }

    # === RÉCUPÉRER TOUS LES DOCUMENTS MATCHANT LA REQUÊTE ===
    list_documents_filtred = QuaiDesDocs.list(list_request, options)

    # L'avertissement
    # ---------------
    # Il ne doit être mis que si ce n'est pas une liste des
    # documents de l'auteur qui est demandé
    avertissement_respect_auteur =
      if user_id == user.id
        'Vous pouvez redéfinir vos partages dans ce listing qui présente tous vos documents.'.in_div(class: 'small italic')
      elsif with_avertissement
        avertissement.to_html.in_div(class: 'cadre warning')
      else
        ''
      end

    if list_documents_filtred.count > 0
      avertissement_alessai_if_needed +
      avertissement_respect_auteur +
      list_documents_filtred.collect do |idoc|
        # Soit le document est partagé, soit il faut indiquer
        # qu'il ne l'est pas et peut-être même le passer.
        if even_not_shared || idoc.shared? || user.id == idoc.owner.id
          doc_card = (
            idoc.form_download +
            ((full_card || infos_docs) ? idoc.bloc_infos : '') +
            (full_card ? idoc.form_cote_or_partage : '')
          )
        else
          # Le document n'est pas partagé. Soit il faut le passer,
          # soit il faut le mettre dans un autre style.
          doc_card = idoc.as_card
        end

        doc_card.in_li(id: "li_doc_qdd-#{idoc.id}", class: 'li_doc_qdd')

      end.join.in_ul(class: 'qdd_documents')
    else
      nil
    end
  end


end #/ << self
end #/QuaiDesDocs
