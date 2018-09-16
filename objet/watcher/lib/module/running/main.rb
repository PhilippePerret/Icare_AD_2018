# encoding: UTF-8
class SiteHtml
class Watcher

  # = main =
  #
  # Méthode principale appelée quand on run le watcher.
  #
  # NOTES
  #   * Le watcher est détruit si l'opération s'est bien déroulée
  #
  def _run
    app.benchmark('-> Watcher#_run')
    app.checkform_on_submit
    raise_if_not_owner_or_admin
    require_objet_watcher_and_required_file
    execute_main_file           || return
    send_mail_watcher_to_admin  || return
    send_mail_watcher_to_user   || return
    @dont_remove_watcher        || remove
    app.benchmark('<- Watcher#_run')
  rescue AlreadySubmitForm => e
    error e
  end

  # Première barrière ne permettant qu'à un administrateur ou
  # au possesseur de ce watcher de le runner
  def raise_if_not_owner_or_admin
    user.admin? || user.id == owner.id || raise('Opération interdite, mon coco, je blackliste ton IP (IP -> Blacklist)…')
  end

  # Le fichier main.rb, s'il existe, est exécuté dans le contexte
  # de ce watcher (comme si c'était le core de la méthode lui-même)
  def execute_main_file
    main_file? || (return true)
    instance_eval(main_file.read)
  rescue Exception => e
    debug e
    error e.message
  else
    true
  end

  # Pour définir le sujet du mail dans les fichiers ERB afin que tout
  # soit regroupé.
  def subject_mail= value; @subject_mail = value end
  alias :mail_subject=  :subject_mail=
  alias :sujet_mail=    :subject_mail=
  def subject_mail
    @subject_mail || raise('Il faut définir le sujet du mail à l’aide de `self.subject_mail = ...` dans le fichier ERB du message.')
  end

  # On doit prendre le message ici pour connaitre le sujet du message
  # Note : on n'utilise pas la méthode #deserb des SuperFile car s'il y
  # a une erreur, elle se retrouverait dans le mail, elle ne serait pas
  # signalée ici
  def mail_message_for dest
    code =
      case dest
      when :admin then admin_mail.read
      when :user  then user_mail.read
      end
    ERB.new(code).result(bind)
  end

  def send_mail_watcher_to_admin
    app.benchmark('-> Watcher#send_mail_watcher_to_admin')
    admin_mail? || (return true)
    # Cf. explication ci-dessus
    mail_message = mail_message_for :admin
    send_mail_to_admin(
      subject:  subject_mail,
      message:  mail_message,
      formated: true
    )
  rescue Exception => e
    debug e
    error e.message
  else
    true
  ensure
    app.benchmark('<- Watcher#send_mail_watcher_to_admin')
  end

  def send_mail_watcher_to_user
    app.benchmark('-> Watcher#send_mail_watcher_to_user')
    user_mail? || (return true)
    @subject_mail = nil # dans le cas où il aurait été défini pour le mail admin
    # Cf. explication ci-dessus
    mail_message = mail_message_for(:user)
    owner.send_mail(
      subject:  subject_mail,
      message:  mail_message,
      formated: true
    )
  rescue Exception => e
    debug e
    error e.message
  else
    true
  ensure
    app.benchmark('<- Watcher#send_mail_watcher_to_user')
  end

end #/Watcher
end #/SiteHtml
