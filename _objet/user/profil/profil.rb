# encoding: UTF-8
=begin

  Module gérant le profil d'un inscrit ou d'un abonné.
  Il permet notamment de rediriger vers l'identification
  si l'user n'est pas identifié.

=end
raise_unless_identified


class User

end #/User

case param(:operation)

when 'save_preferences'
  User.require_module 'preferences'
  user.save_preferences
end

# Liste des redirections possibles après le login
# Elles sont définies dans site/config.rb et dans le
# fichier ./_objet/user/lib/required/user/instance/redirections.rb
def liste_goto_after_signin
  @liste_goto_after_signin ||= begin
    site.redirections_after_login.collect do |val, ddir|
      next if ddir[:admin] && !user.admin?
      [val, ddir[:hname]]
    end.compact
  end
end
