# encoding: UTF-8
# Bizarrement, ça pose problème alors que partout avant
# user est défini comme identifié…
# J'ai mis ONLINE pour que ça soit invisible en online mais
# visible en local

# Je ne sais pas pourquoi, mais en arrivant ici, user.id est nil
# Il faut donc appeler cette méthode pour forcer les choses
# reset_user_current

raise_unless_admin
class Admin
  class << self

    def table_taches
      @table_taches ||= site.dbm_table(:hot, 'taches')
    end

    def table_taches_cold
      @table_taches_cold ||= site.dbm_table(:cold, 'taches')
    end

  end #/ << self
end #/Admin
