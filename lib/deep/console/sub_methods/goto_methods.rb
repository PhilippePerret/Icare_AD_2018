# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  def goto_section section_name
    # Pour ajouter des descriptions (nouveaux paramètres) au manuel,
    # les ajouter dans le fichier ./lib/deep/console/help.rb
    redirection = case section_name
    when "accueil", "home"                  then '/'
    when 'forum'                            then 'forum/home'
    when /^(admin|dashboard)$/              then 'admin/dashboard'
    when /^(sync|synchro|synchronisation)$/ then 'admin/sync'
    else
      # On essaie les directions de l'application
      console.require('optional/goto_methods.rb')
      ( app_goto_section section_name )
    end
    redirect_to redirection unless redirection.nil?
    ""
  end
end #/Console
end #/Admin
end #/SiteHtml
