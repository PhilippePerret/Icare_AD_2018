# encoding: UTF-8
=begin

  Méthodes générales pratiques

=end

# Permet d'envoyer un message à l'admininistrateur suite à une
# erreur.
#
# +args+
#   Peut être soit simplement l'erreur elle-même, soit un Hash
#   contenant :
#   :exception      L'erreur complète rencontrée, avec #message et
#                   # backtrace
#   :url            L'url, if any.
#   :file           Le path du fichier qui a posé problème, if any
#   :from           La provenance de l'erreur, même si elle peut
#                   être retrouvée dans backtrace
#   :extra          Pour envoyer d'autres données
def send_error_to_admin args
  args =
    case args
    when Hash then args
    else {exception: args}
    end

  message, backtrace =
    case args[:exception]
    when String then [args[:exception], '']
    else [args[:exception].message, "BACKTRACE \n" + args[:exception].backtrace.join("\n")]
    end


  message = <<-HTML
<p>Erreur sur #{site.name}</p>
<p>
  Date : #{Time.now.to_i.as_human_date(true, true, ' ', 'à')}
</p>
<p>
  User : #{user.identified? ? "#{user.pseudo} (#{user.id})" : '- inconnu -'}<br>
  User IP : #{user.ip}
</p>
<pre style="font-size:11pt">
  MESSAGE : #{message}
  #{backtrace}
</pre>
  HTML
  # Ajout des informations supplémentaires
  if args[:from]
    message += "Cette erreur a été rencontrée depuis : #{args[:from]}".in_p
  end
  if args[:file]
    message += "Erreur rencontrée sur le fichier : #{args[:file]}".in_p
  end
  if args[:url]
    message += "Erreur rencontrée avec l'URL : #{args[:url]}".in_p
  end
  if args[:extra]
    message += "Autres informations (extra) : #{args[:extra]}"
  end

  site.send_mail_to_admin(
    subject:      "ERREUR SUR #{site.name}",
    message:      message,
    # force_offline:  true, # pour les essais
    formated:     true,
    no_header:    true
  )
end
