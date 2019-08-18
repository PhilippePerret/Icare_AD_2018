# encoding: UTF-8

begin


  imodule = IcModule.new(site.current_route.objet_id)

  # Vérification que le module existe bien
  imodule.exist? || raise('Ce module n’existe pas. Si vous tentez de forcer le site, vous allez être placé sur sa liste noire.')

  # Vérification que l'utilisateur peut le faire.
  user.admin? || imodule.user_id == user.id || raise('Vous n’êtes pas autorisé à redémarrer ce module. Si vous insistez, vous allez être banni de l’atelier.')

  # Changement du bit du module
  imodule.set(options: imodule.options.set_bit(1,1))

  # Enregistrer la fin de pause.
  # Note : on se sert de la dernière pause enregistrées
  imodule.stop_pause

  send_mail_to_admin(
    subject:      'Redémarrage de module d’apprentissage',
    no_citation:  true,
    formated:     true,
    message:      "Phil, je t'informe que #{user.pseudo} (##{user.id}) vient de redémarrer son module d'apprentissage (#{imodule.titre})".in_div
  ) rescue nil

  flash "Redémarrage du module d'apprentissage opéré avec succès."

rescue Exception => e
  debug e
  error e.message
ensure
  redirect_to :last_page
end
