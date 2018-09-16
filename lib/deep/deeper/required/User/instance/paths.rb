# encoding: UTF-8
class User

  # Dossier dans ./database/data/user/
  def folder
    @folder ||= site.get_and_build_folder(site.folder_db_users + "#{id}")
  end

end
