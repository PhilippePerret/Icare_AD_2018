# encoding: UTF-8
=begin

  Module appelé quand on clique sur "Code oublié"

=end
if param(:umail)

  if param(:umail) && param(:umail).nil_if_empty.nil?
    error 'Merci d’indiquer l’adresse mail.'
  elsif
    duser = User.table.get(where: {mail: param(:umail)})
    if duser.nil?
      error 'Ce mail est inconnu sur le site.<br>Avez-vous bien fourni votre mail d’inscription ?'
    else
      require 'securerandom'
      require 'digest/md5'

      begin

        # Trouver un nouveau mot de passe
        new_password  = SecureRandom.urlsafe_base64(10)
        new_cpassword = Digest::MD5.hexdigest("#{new_password}#{param :umail}#{duser[:salt]}")

        # On fait une instance provisoire de l'utilisateur
        u = User.new(duser[:id])

        # Enregistrer le nouveau mot de passe dans la base de données
        u.set(cpassword: new_cpassword)

        # Envoyer le mail informant du nouveau mot de passe
        votre_profil = 'votre profil'.in_a(href: "#{site.distant_url}/user/#{u.id}/profil")
        u.send_mail(
          subject: 'Votre nouveau mot de passe',
          message:  "<p>Bonjour #{u.pseudo}</p>" +
                    "<p>Votre nouveau mot de passe : #{new_password}</p>" +
                    "<p>Vous pouvez bien sûr le modifier depuis #{votre_profil}.</p>",
          formated:   true,
          force_offline: true
        )
        flash "#{duser[:pseudo]}, un mail vous a été envoyé avec<br>un nouveau mot de passe provisoire."

      rescue Exception => e
        debug e
        error 'Une erreur s’est malheureusement produite.<br>Impossible de vous fournir un nouveau mot de passe.'
        error 'Merci de contacter l’administration si le problème se reproduisait.'
      end


    end
  end

end
