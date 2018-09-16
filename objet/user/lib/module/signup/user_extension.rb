# encoding: UTF-8
=begin
Extension de la class User pour la route user/signup
=end
class User
  def mail_confirmation; param(:user_mail_confirmation) || "" end
  def password; "" end
  def password_confirmation; "" end
end
