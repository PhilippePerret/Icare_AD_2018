# encoding: UTF-8
class SiteHtml
class Watcher

  # RETURN le code HTML du LI pour le watcher, mais seulement
  # s'il existe pour l'user (en fonction du fait qu'il est administrateur
  # ou non) et en fonction du fait que'il est déclenché (si son trigger
  # est défini)
  # RETURN Nil si la notification n'existe pas où qu'il ne faut pas
  # la retourner.
  def as_li options = nil
    require_objet_watcher_and_required_file
    # Toutes les raisons de retourner NIL
    triggered && Time.now.to_i < triggered && return
    user.admin? && !admin_notify? && return
    !user.admin? && !user_notify? && return
    # On doit faire la notification
    notify = (user.admin? ? admin_notify : user_notify).deserb(self)
    notify = (user.admin? ? admin_notify : user_notify).deserb(self)
    notify.in_li(class: 'notify', id: li_id)
  rescue Exception => e
    debug e
    send_error_to_admin(
      exception: e,
      from:       "`as_li` du watcher ayant pour donnée : id: #{id.inspect}, user_id: #{user_id.inspect}, processus: #{processus.inspect}, objet: #{objet.inspect}, objet_id: #{objet_id.inspect}, data: #{data.inspect}"
    ) rescue nil
    'Cette notification n’a pas pu être affichée, mais l’administration a été avertie et va s’empresser de régler le problème.'.
      in_li(class: 'notify', id: li_id)
  end

  # Permet de construire facilement un formulaire conforme
  # Cf. le refbook > Watchers.md
  def form args = nil
    args = form_attributs_avec args
    (
      app.checkform_hidden_field(args[:id]) +
      yield
    ).in_form(args)
  rescue AlreadySubmitForm => e
    error e.message
  rescue Exception => e
    debug e
    return "<div>Impossible de construire le formulaire du watcher ##{id} : #{e.message}</div>"
  end

  # Permet de construire facilement un formulaire conforme
  # Cf. le refbook > Watchers.md
  def form_entete args = nil
    args = form_attributs_avec(args)
    String.opened_tag('form', args)
  end

  # ---------------------------------------------------------------------
  #   Méthode fonctionnelles pour helpers
  # ---------------------------------------------------------------------
  def form_attributs_avec args
    args ||= Hash.new
    args[:action]   ||= "watcher/#{id}/run"
    args.key?(:id)  || args.merge!(id: "form_watcher-#{id}")
    return args
  end

  def li_id
    @li_id ||= "li_watcher-#{id}"
  end


end#/Watcher
end#/SiteHtml
