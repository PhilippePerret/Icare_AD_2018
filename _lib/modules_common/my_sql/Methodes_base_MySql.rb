# encoding: UTF-8
module MethodesBaseMySQL

  # Permet de définir sur quelle base doit être effectuées
  # les opérations
  def define_is_offline force_online
    if ONLINE
      @@is_offline = false
    else
      @@is_offline =
        case force_online
        when NilClass then OFFLINE
        when false    then true   # Pour la clarté (!force_online)
        when true     then false  # Pour la clarté (!force_online)
        end
    end
  end

  def offline?
    @@is_offline = ( OFFLINE == true ) if @@is_offline === nil
    @@is_offline
  end

  def client
    Mysql2::Client.new(client_data.merge(database: db_name))
  end

  def client_sans_db
    Mysql2::Client.new(client_data)
  end

  # Les données pour se connecter à la base mySql
  # soit en local soit en distant.
  def client_data
    if offline?
      client_data_offline
    else
      client_data_online
    end
  end

  def client_data_offline
    require './data/secret/mysql'
    DATA_MYSQL[:offline]
  end

  def client_data_online
    require './data/secret/mysql'
    DATA_MYSQL[:online]
  end

  def db_name     ; prefix_name + suffix_name.to_s end
  def suffix_name ; _suffix_name end

  # Le préfixe du nom (de la base de données) en fonction
  # du fait qu'on est online ou offline
  #
  # Normalement, maintenant, on peut utiliser les deux en
  # online comme en offline.
  #
  def prefix_name
    @@prefix_name ||= "#{site.prefix_databases}_" # p.e. 'boite-a-outils_'
  end
end
