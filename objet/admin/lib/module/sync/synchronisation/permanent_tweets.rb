# encoding: UTF-8
class Sync
  def synchronize_permanent_tweets
    @report << "* Synchronisation des TWEETS PERMANENTS"
    if Sync::PTweets.instance.synchronize(self)
      @suivi << "= Synchronisation des TWEETS PERMANENTS opérée avec SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation des TWEETS PERMANENTS".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class PTweets
  include Singleton
  include CommonSyncMethods

  # Les tweets permanents sont ajoutés en local donc il faut
  # synchroniser la table distante. En revanche, la table
  # distante contient les informations d'envoi de ces tweets
  # que l'on peut reporter dans la table locale, pour information
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    loc_rows.each do |tid, loc_data|
      dis_data = dis_rows[tid]

      if dis_data.nil?
        # La donnée distante n'existe pas
        # => Il faut la créer
        # ====== ACTUALISATION =========
        dis_table.insert( loc_data )
        @nombre_synchronisations += 1
        # ===============================
        report "CRÉATION du tweet permanent DISTANT ##{tid}"
      elsif dis_data != loc_data
        # Données distante différente de donnée locale
        # Deux cas peuvent se poser :
        # 1. Le tweet distant possède un :count et/ou un
        #    :last_sent différents de la donnée locale
        #    => il faut actualiser la donnée locale.
        # 2. Si les deux tweets sont toujours différents,
        #    il faut aussi actualiser les autres propriétés
        #    de la donnée distante.
        if (dis_data[:count].to_i > loc_data[:count].to_i) || (dis_data[:last_sent] != loc_data[:last_sent])
          # Cas 1.
          # Il faut mettre tout de suite les données dans loc_data
          # pour la comparaison suivante
          count = dis_data[:count]
          lsent = dis_data[:last_sent]
          loc_data[:count]      = count
          loc_data[:last_sent]  = lsent
          # ================== ACTUALISATION =======================
          loc_table.update(tid, {count: count, last_sent: lsent})
          @nombre_synchronisations += 1
          # ========================================================
          report "UPDATE des :count et :last_sent du tweet LOCAL ##{tid}"
        end
        # Si les deux données sont toujours différentes, c'est qu'il
        # faut actualiser la donnée distante
        if dis_data != loc_data
          # ================== ACTUALISATION =======================
          loc_data.delete(:id)
          dis_table.update(tid, loc_data)
          @nombre_synchronisations += 1
          # ========================================================
          report "UPDATE du tweet permanent DISTANT ##{tid}"
        end
      else
        # Deux données identiques => rien à faire
        suivi "Tweet permanent ##{tid} loc/dis identiques"
      end

    end

    if @nombre_synchronisations > 0
      report "  = NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation des TWEETS PERMANENTS opérée avec SUCCÈS'.in_span(class: 'blue bold')
    end
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  def db_suffix
    @db_suffix ||= :cold
  end
  def table_name
    @table_name ||= 'permanent_tweets'
  end
end #/Filmodico
end #/Sync
