# encoding: UTF-8
class SiteHtml
class Watcher

  def main_file   ; @main_file  ||= folder + 'main.rb'        end
  def admin_mail  ; @admin_mail ||= folder + 'admin_mail.erb' end
  def user_mail   ; @user_mail  ||= folder + 'user_mail.erb'  end

end #/Watcher
end #/SiteHtml
