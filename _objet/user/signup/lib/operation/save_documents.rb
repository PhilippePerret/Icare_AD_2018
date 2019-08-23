# encoding: UTF-8
class Signup
class << self

  # Méthode qui sauve les données d'identité dans un fichier marshal
  # provisoire avant de passer à la suite de l'inscription
  def save_documents
    data_documents_valides? || (return false)
    # Les documents ont pu être téléchargés, on peut passer
    # à la suite (qui verra la création réelle de l'user)
    # On crée juste un fichier Marshal pour que l'application
    # détecte que cette étape de l'inscription a été faite
    # Mais on ne met rien dedans
    marshal_file('documents').write Marshal.dump(@data_documents)
    return true
  end

  # Retourne les données des documents, qui consiste simplement
  # en un hash définissant le nom des documents, mais simplement pour
  # avoir directement leur extension, sinon les noms sont standardisés
  # à 'Document_presentation.<ext>' etc.
  def get_documents
    marshal_file('documents').exist? || return
    Marshal.load(marshal_file('documents').read)
  end

  def data_documents_valides?
    folder_tmp_documents.remove if folder_tmp_documents.exist?
    @data_documents = {
      presentation: nil, motivation: nil, extrait: nil
    }
    traite_documents_presentation
  end

  # Dossier dans lesquels les documents seront déposés
  def folder_tmp_documents
    @folder_tmp_documents ||= folder_tmp_session + 'documents'
  end

  # Traitement des documents de présentation
  #
  # Retourne TRUE en cas de succès et FALSE en cas d'échec
  def traite_documents_presentation
    {
      presentation: {required: true,  hname: "Présentation"},
      motivation:   {required: true,  hname: "Motivation"},
      extrait:      {required: false, hname: "Extrait"}
    }.each do |doc_id, ddata|
      case traite_document_presentation(doc_id)
      when NilClass
        # Pas de document de ce type envoyé. Si ça n'est pas un document
        # obligatoire, on poursuit
        # Normalement, ça ne doit pas pouvoir arriver car javascript empêche
        # de soumettre le formulaire sans les deux documents obligatoires.
        !ddata[:required] || raise("Le document “#{ddata[:hname]}” est absolument requis.")
      when FalseClass
        raise "Le document “#{ddata[:hname]}” n'a pas pu être uploadé."
      end
    end
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Traite le document d'identifiant +doc_ic+ (p.e. 'presentation') et
  # le met dans le dossier temporaire de la session.
  #
  # RETURN
  #   True  en cas de succès
  #   Nil   si le document n'existe pas
  #
  # signup_documents[presentation] # ou motivation ou extrait
  def traite_document_presentation doc_id
    doc_tempfile  = param(:signup_documents)[doc_id]
    doc_extension = File.extname(doc_tempfile.original_filename)
    doc_name      = "Document_#{doc_id}#{doc_extension}"
    doc_file      = folder_tmp_documents + doc_name
    res = doc_file.upload(doc_tempfile, {change_name: false, nil_if_empty: true})
    res && @data_documents[doc_id] = doc_name
    return res
  end

end #/<< self
end #/ Signup
