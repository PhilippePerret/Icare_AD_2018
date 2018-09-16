# encoding: UTF-8
=begin

Instance d'un gel en particulier

=end
require 'fileutils'
class SiteHtml
class Gel

  # Nom du gel, i.e. nom du dossier contenant ses éléments
  attr_reader :name

  def initialize gel_name
    @name = gel_name.strip
  end

  # ---------------------------------------------------------------------
  # Les deux méthodes de gel principales
  #
  # +options+ Pour le moment, inutilisé
  # RETURN True (principalement pour la console)
  def gel options = nil
    return false if name_invalide?
    # debug "===> gel"
    folder.remove if exist?
    FileUtils::cp_r site.folder_db.to_s , folder.to_s
    # debug "<=== gel"
    true
  end
  # RETURN True (principalement pour la console) si tout s'est
  # bien passé, false otherwise
  def degel options = nil
    # debug "===> degel"
    return false if name_invalide?
    if exist?
      get_admin_session_id
      backup_and_delete_current_folder_data
      FileUtils::cp_r folder.to_s, site.folder_database.to_s
      # Pour le moment, le dossier gel porte dans ./database le nom
      # du gel. Il faut lui remettre le nom 'data'
      as_folder_database.rename 'data'
      # Pour essayer de corriger l'erreur qui dit à set_admin_session_id
      # que la base est readonly.
      # change_folders_perm
      # Reset des variables d'instance des anciennes bases
      reset_instance_variables_db
      # Reconnecter les administrateurs
      set_admin_session_id
      true
    else
      error "Le gel `#{name}` n'existe pas."
      false
    end
    # debug "<=== degel"
  end
  #
  # ---------------------------------------------------------------------

  # Si on dégele un gel effectué sous une autre session, l'administrateur
  # perd son login et doit se reconnecter. Pour éviter ça, on prend l'id
  # de session qui est actuellement défini pour les administrateurs et
  # on les remet dans le dégel opéré.
  def get_admin_session_id
    sessid = app.session.session_id
    @connected_admins = User::table.select(colonnes:[:session_id], where:"(options NOT LIKE '0%') AND session_id = '#{sessid}'")
    # debug "admins trouvés : #{@connected_admins.pretty_inspect}"
    # debug "<- get_admin_session_id"
  rescue Exception => e
    error "# Erreur en essayant de prendre les administrateurs connectés : #{e.message}"
    debug e
  end

  # On reconnecte les administrateurs après le dégel
  # Mais attention, ces administrateurs peuvent très bien ne plus exister
  # lorsque ce sont des tests par exemple. Donc il faut checker avant que
  # ce soit possible.
  def set_admin_session_id
    # debug "-> set_admin_session_id"
    @connected_admins.each do |uid, udata|
      admin = User::get(uid)
      next unless admin.exist?
      next unless admin.admin?
      admin.set(session_id: app.session.session_id)
    end
    # debug "<- set_admin_session_id"
  rescue Exception => e
    error "# Erreur en essayant de reconnecter les administrateurs : #{e.message}"
    debug e
  end

  # Il faut réinitialiser les variables @ qui sont encore connectées
  # avec les anciennes bases de données pour obliger leur reconnection
  # avec les nouvelles tables
  def reset_instance_variables_db
    User::instance_variables.each do |inst|
      User::instance_variable_set(inst, nil)
    end
  end

  # Pour tenter de régler le problème de database readonly,
  # mais ça ne vient pas de là apparemment.
  def change_folders_perm
    Dir["./database/**/*"].each do |path|
      next unless File.directory?(path)
      # debug "Modification des permissions de #{path}"
      res = FileUtils.chmod( 0755, path, :verbose => true)
      # debug res
    end
  end

  def name_invalide?
    raise "Il faut préciser le nom du gel." if name.empty?
    raise "`__backup__` est un nom réservé." if name == "__backup__"
    raise "Les noms ne peuvent pas contenir d'espaces." if name.match(/ /)
    not_ok = name.gsub(/[a-zA-Z0-9_\.\-]/,'') != ""
    raise "Les noms ne peuvent contenir que a-z, A-Z, 0-9, `_`, `.` et -" if not_ok
  rescue Exception => e
    error e
    true # Not OK
  else
    false # OK
  end
  def backup_and_delete_current_folder_data
    # debug "-> backup_and_delete_current_folder_data"
    as_folder_backup.remove if as_folder_backup.exist?
    FileUtils::cp_r   site.folder_db.to_s, as_folder_backup.to_s
    FileUtils::rm_rf  site.folder_db.to_s
    # debug "<- backup_and_delete_current_folder_data"
  end

  def exist?
    folder.exist?
  end

  # Le chemin du dossier data/backup
  def as_folder_backup
    @as_folder_backup ||= (self.class::folder + '__backup__')
  end

  # Le path du dossier quand il se trouve copié du dossier des gels
  # vers le dossier database. Il porte son nom de gel et il faudra
  # lui donner le nom 'data'
  def as_folder_database
    @as_folder_database ||= site.folder_database + name
  end

  # {SuperFile} Dossier contenant les éléments du gel
  def folder
    @folder ||= self.class::folder + name
  end

end #/Gel
end #/SiteHtml
