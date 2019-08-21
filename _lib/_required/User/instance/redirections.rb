# encoding: UTF-8
=begin

  Méthodes s'occupant de la redirection de l'user après son login

=end
class User

  # Redirection de l'user après son login
  def redirect_after_login
    app.benchmark('-> redirect_after_login')

    kroute =
      if user.pref_goto_after_login
        site.redirections_after_login[user.pref_goto_after_login][:route]
      else
        :noredirection
      end
    debug "kroute = #{kroute.inspect}"
    # redirect_to route_for(kroute)
    # Maintenant, c'est une vraie redirection qui est provoquée
    page.redirect_to(route_for(kroute))
    app.benchmark('<- redirect_after_login')
  end

  def route_for key
    case key
    when :home          then 'site/home'
    when :bureau        then "bureau/#{user.id}/home"
    when :profil        then "user/#{user.id}/profil"
    when :last_page     then dbtable_connexions.get(user.id)[:route]
    when :noredirection then 'user/login'
    else key # une route déjà formatée
    end
  end

end
