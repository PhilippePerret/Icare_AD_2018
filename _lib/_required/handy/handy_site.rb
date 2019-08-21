# encoding: UTF-8

def redirect_to route
  site.redirect_to route
end

def send_mail_to_admin(data_mail);site.send_mail_to_admin(data_mail)end

# {String} Retourne la route courante en tant que string
# Attention, ça n'est pas `site.current_route` qui retourne
# une instance {SiteHtml::Route}.
def current_route
  if site.current_route.nil?
    nil
  else
    site.current_route.route
  end
end
alias :route_courante :current_route

# Pour détruire le code HTML de la page d'accueil suite à
# une nouvelle actualité pour contraindre à l'actualiser
def destroy_home
  site.destroy_home
end

def osascript script
  site.osascript script
end



# ---------------------------------------------------------------------
#   Barrières de protection des vues et modules
# ---------------------------------------------------------------------
class ErrorUnidentified < StandardError; end
class ErrorNoAdmin < StandardError; end
class SectionInterditeError < StandardError; end
class ErrorNotOwner < StandardError; end

# Barrière anti non-identifié
# Cf. RefBook > Protection.md
def raise_unless_identified
  user.identified? && return
  unless @error_must_identified_done
    # L'erreur qu'on doit faire apparaitre dans la page, pas
    # dans un message flash
    page.error_in_page 'Vous devez être connu du site pour rejoindre la page demandée. Merci de vous identifier ci-dessous.'
    redirect_to 'user/login'
    @error_must_identified_done = true
  end
end

# Barrière anti non-administrateur
# Si l'user n'est pas identifié, on l'envoie plutôt à l'identification
# Sinon, il rejoint la page d'erreur normale.
# Cf. RefBook > Protection.md
def raise_unless_admin
  if user.identified?
    raise ErrorNoAdmin unless user.admin?
  else
    unless @error_must_identified_done
      page.error_in_page 'Vous devez être administrateur du site pour rejoindre la page demandée. Merci de vous identifier ci-dessous.'
      redirect_to 'user/login'
      @error_must_identified_done = true
    end
  end
end
# Barrière anti non quelque chose
# Cf. RefBook > Protection.md
def raise_unless condition, error_message = nil, need_identified = false
  if false == condition
    if need_identified
      page.error_in_page 'Merci de vous identifier pour rejoindre la page souhaitée.'
      redirect_to 'user/login'
    else
      raise SectionInterditeError, error_message
    end
  end
end
# Cf. RefBook > Protection.md
def raise_unless_owner message = nil
  return true if user.admin?
  raise ErrorNotOwner, message
end
