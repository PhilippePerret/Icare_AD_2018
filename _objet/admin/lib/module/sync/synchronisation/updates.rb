# encoding: UTF-8
class Sync
  def synchronize_updates
    @report << "* Synchronisation des UPDATES"
    if Sync::Updates.instance.synchronize(self)
      @suivi << "= Synchronisation des UPDATES opérée avec SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation des UPDATES".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Updates
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    loc_rows.each do |uid, loc_data|
      dis_data = dis_rows[uid]
      if dis_data.nil?
        # La donnée distante n'existe pas
        # => La créer
        # ====== ACTUALISATION =======
        dis_table.insert(loc_data)
        @nombre_synchronisations += 1
        # ============================
        report "  = Actualité ##{uid} DISTANTE créée."
      elsif dis_data != loc_data
        # La donnée distante est différente de la données locale
        # => Actualisation la donnée distante
        # ========= ACTUALISATION =========
        loc_data.delete(:id)
        dis_table.update(uid, loc_data)
        @nombre_synchronisations += 1
        # ==================================
        report "  = Actualité ##{uid} DISTANTE actualisée."
      else
        # Données identiques
        # => Ne rien faire
        suivi "= Actualité ##{uid} loc/dis identiques"
      end
    end
    # /Fin de boucle sur toutes les rangées locales

    # Il peut arriver qu'on détruise des données locales suite
    # à des erreurs (ou des tests). Il faut les actualiser au
    # besoin. Noter qu'on ne fait l'opération que si la donnée
    # locale n'existe, donc il faut la détruire pour l'actualiser
    dis_rows.each do |uid, dis_data|
      if loc_rows[uid].nil?
        loc_table.insert(dis_data)
        @nombre_synchronisations += 1
        report "  = Actualité LOCALE ##{uid} créée."
      end
    end
    # /Fin de boucle sur toutes les rangées distantes

    if @nombre_synchronisations > 0
      report "  = NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation des UPDATES opérée avec SUCCÈS'.in_span(class: 'blue bold')
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
    @table_name ||= 'updates'
  end
end #/Updates
end #/Sync
