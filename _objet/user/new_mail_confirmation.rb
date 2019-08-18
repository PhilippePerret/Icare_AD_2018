# encoding: UTF-8
=begin

  Voir l'explication dans le fichier ERB

=end
class User
class << self

  def send_mail_confirmation_mail
    umail = param(:user_mail).nil_if_empty
    umail != nil        || raise('Vous devez indiquer votre mail dans le champ “Votre mail”.')
    umail.match(/@/)    || raise('Vous devez indiquer une adresse mail valide !')
    user_id = mail_exists?(umail)
    user_id != nil || raise('Désolé, mais ce mail est inconnu sur ce site. Comment pourriez-vous le confirmer ?')

    # Tout est OK, on peut renvoyer un message pour que
    # l'user confirme son mail.

    # On crée une instance user provisoire pour que la
    # vue puisse faire le ticket de confirmation.
    u = User.new(user_id)

    pmail = folder_modules + 'create/mail_confirmation.erb'
    u.send_mail(
      subject: 'Merci de confirmer votre mail',
      message: pmail.deserb(u),
      formated: true,
      force_offline: true
    )

    flash 'Un mail vient de vous être envoyé pour confirmer votre adresse mail.'
    param(user_mail: '')

  rescue Exception => e
    error e.message
  end

  # Vérifie que le mail +umail+ corresponde à un enregistrement
  # et retourne NIL si ce n'est pas le cas OU l'identifiant de
  # l'user dans le cas contraire.
  def mail_exists? umail
    duser = table_users.get(where: {mail: umail})
    if duser.nil?
      nil
    else
      duser[:id]
    end
  end

end #/<<self
end #/User

case param(:operation)
when 'send_mail_confirmation_mail'
  # On passe par ici lorsque l'user a indiqué son adresse mail
  # et cliquer sur le bouton pour soumettre le formulaire
  User.send_mail_confirmation_mail
end
