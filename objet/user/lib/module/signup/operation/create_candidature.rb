# encoding: UTF-8
class Signup
class << self

  # = main =
  #
  # Méthode finale qui construit la candidature du candidat
  def create_candidature
    all_data_valides? || return
    not_rechargement_page? || begin
      flash 'Merci de ne pas recharger la page.'
      return
    end

    # On crée le nouvel utilisateur (et on le met en utilisateur
    # courant)
    User.require_module 'create'
    param(data_identite: @data_identite)
    User.create_new_user

    # Watcher pour valider l'inscription
    user.add_watcher(
      objet:      'user',
      objet_id:   user.id,
      processus:  'valider_inscription',
      data:       app.session.session_id
    )
  end

  # Retourne true si c'est un rechargement de page (on le repère
  # au fait que l'user est déjà créé)
  def not_rechargement_page?
    user && user.mail || (return true)
    dbtable_users.count(where:{mail: user.mail}) == 0
  end

  # On s'assure que toutes les données sont valides
  def all_data_valides?
    @data_identite = get_identite
    @data_identite || raise('Impossible de trouver les données d’identité. Je ne peux pas créer votre candidature.')
    @data_modules = get_modules
    @data_modules  || raise('Impossible de trouver les données de modules. Je ne peux pas créer votre candidature.')
    @data_documents = get_documents
    @data_documents || raise('Impossible de trouver la données des documents. Je ne peux pas créer votre candidature.')
    @data_documents.each do |doc_id, doc_name|
      doc_name != nil || next
      doc_path = folder_tmp_documents + doc_name
      doc_path.exist? || raise("Le document `#{doc_name}` est introuvable… Je ne peux pas enregistrer votre candidature.")
    end
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end


end #/<< self
end #/Signup
