# encoding: UTF-8
=begin

  Méthodes pour toutes les paths des processus

=end
class SiteHtml
class Watcher

  # === Paths ===
  # Note : les paths pour main.rb et les mails sont dans le module 'running'
  def admin_notify  ; @admin_notify   ||= folder + 'admin_notify.erb' end
  def user_notify   ; @user_notify    ||= folder + 'user_notify.erb'  end
  def required_file ; @required_file  ||= folder + 'required.rb'      end

  # === Tests existence fichiers ===
  def admin_notify?   ; admin_notify.exist?   end
  def user_notify?    ; user_notify.exist?    end
  def required_file?  ; required_file.exist?  end

  # Le dossier où est défini le watcher
  def folder
    @folder ||= site.folder_objet + "#{objet}/lib/_processus/#{processus}"
  end

end #/Watcher
end #/SiteHtml
