# encoding: UTF-8
class User
  class << self

    # Autologin d'un administrateur, par exemple pour les
    # tickets.
    #
    # ATTENTION : penser à appeler `delogin_admin` à la fin
    # du code du ticket pour empêcher toute intrusion.
    #
    def autologin_admin( who = :phil)
      require "./data/secret/data_#{who}"
      data_who =
        case who
        when :phil    then DATA_PHIL
        when :marion  then DATA_MARION
        end
      new(data_who[:id]).autologin
    end

    def delogin_admin
      current.deconnexion
    end

  end #/ << self
end #/ User
