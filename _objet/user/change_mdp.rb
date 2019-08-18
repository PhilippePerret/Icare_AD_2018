# encoding: UTF-8
raise_unless_identified
=begin

  Module pour modifier son mot de passe

=end
class User

  def change_mot_de_passe
    check_new_mot_de_passe  || return
    save_mot_de_passe       || return
    send_mdp_via_mail       || return
    flash "#{pseudo}, votre nouveau mot de passe a été enregistré.<br>Il vous a été également transmis par mail."
    param(user_mdp: '')
    param(user_mdp_confirmation: '')
    redirect_to "user/#{id}/profil"
  end

  # Envoi d'un mail pour confirmer le nouveau mot de passe
  def send_mdp_via_mail
    self.send_mail(
      subject: 'Changement de mot de passe',
      message: "<p>#{pseudo},</p>" +
      '<p>Votre nouveau mot de passe, tel que modifié sur le site :</p>'+
      "<pre>        #{new_mdp}</pre>" +
      '<p>Bonne continuation à vous sur la Boite.</p>',
      formated: true
    )
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Enregistrement du nouveau mot de passe
  def save_mot_de_passe
    set( cpassword: new_cpassword )
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Retourne le mot de passe crypté
  def new_cpassword
    @new_cpassword ||= begin
      require 'digest/md5'
      Digest::MD5.hexdigest("#{new_mdp}#{mail}#{get :salt}")
    end
  end

  # Vérification des données transmises
  def check_new_mot_de_passe
    new_mdp != nil        || raise('Il faut fournir un mot de passe !')
    conf_mdp != nil       || raise('Il faut fournir la confirmation du mot de passe.')
    new_mdp.length <= 40  || raise('Le mot de passe ne doit pas excéder 40 signes.')
    new_mdp.length >= 8   || raise('Le mot de passe doit faire au moins 8 caractères.')
    new_mdp == conf_mdp   || raise('La confirmation du mot de passe ne correspond pas, malheureusement.')
  rescue Exception => e
    error e.message
  else
    true
  end

  def new_mdp
    @new_mdp ||= param(:user_mdp).nil_if_empty
  end
  def conf_mdp
    @conf_mdp ||= param(:user_mdp_confirmation).nil_if_empty
  end

end

case param(:operation)
when 'change_motdepasse'
  user.change_mot_de_passe
end
