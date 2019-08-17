# encoding: UTF-8
=begin
Méthodes pratiques pour la classe User
=end

# `user`, dans le programme, correspond à l'utilisateur qui
# visite actuellement le site. Il peut être identifié.
#
# Note : Ne pas mettre '@user ||= User::current' sinon ça
# pose des problèmes lors de l'identification, ou on perd
# la bonne instance, malgré l'utilisation de reset_user_current
def user
  User.current
end
# def reset_user_current
#   @user = nil
# end
