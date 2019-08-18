# encoding: UTF-8
class Sync
  def synchronize_analyses
    @report << "* Synchronisation des Analyses de films"
    if Sync::Analyses.instance.synchronize(self)
      # OK
    else
      mess_err = "# ERREUR pendant la synchronisation des Analyses de films".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Analyses
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0
    synchronize_films_analyses
    synchronize_travaux_analyses
    synchronize_fichiers_analyses
    if @nombre_synchronisations > 0
      report "  NOMBRE DE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue')
      report '  Synchronisation des Analyses de films OPÉRÉE AVEC SUCCÈS'.in_span(class: 'blue')
    end
  rescue Exception => e
    debug e
    error e.message
    false
  else
    true
  end


  def synchronize_films_analyses
    report "  * Synchronisation de la table 'films_analyses'"

    self.table_name = "films_analyses"

    loc_rows.each do |fid, loc_fdata|

      dis_fdata = dis_rows[fid]

      loc_fdata_sans_id = loc_fdata.dup
      loc_fdata_sans_id.delete(:id)
      unless dis_fdata.nil?
        dis_fdata_sans_id = dis_fdata.dup
        dis_fdata_sans_id.delete(:id)
      end


      if dis_fdata.nil?
        # Donnée inexistante sur le site distant (normalement,
        # ça ne devrait pas pouvoir exister)
        # => Créer la donnée sur le site distant
        # ============ ACTUALISATION =============
          dis_table.insert(loc_fdata)
          @nombre_synchronisations += 1
        # =========================================
        report "  * Création de la donnée film ##{fid} (#{loc_fdata.inspect})"
      elsif dis_fdata != loc_fdata
        # Les données sont divergentes
        # => Il faut actualiser les données distantes, car c'est
        #    toujours en offline qu'on les modifie.
        #    On fait quand même une vérification sur updated_at
        #     pour être sûr.
        if dis_fdata[:updated_at] < loc_fdata[:updated_at]
          # loc -> dis
          # ============ ACTUALISATION =============
            dis_table.update(fid, loc_fdata_sans_id)
            @nombre_synchronisations += 1
          # =========================================
          report "  = Actualisation de la donnée DISTANTE ##{fid}"
        else
          # dis -> loc
          # ============ ACTUALISATION =============
            loc_table.update(fid, dis_fdata_sans_id)
            @nombre_synchronisations += 1
          # =========================================
          report "  = Actualisation de la donnée LOCALE ##{fid}"
        end
      else
        # Les deux données sont identiques => rien à faire
      end
    end
    report "  = Table 'films_analyses' synchronisée"
  end

  def synchronize_travaux_analyses
    self.table_name = "travaux_analyses"
    report "  * Synchronisation de la table 'travaux_analyses'"
    dis_rows.each do |wid, dis_data|
      loc_data = loc_rows[wid]
      if loc_data.nil?
        # ======== ACTUALISATION =======
        loc_table.insert(dis_data)
        @nombre_synchronisations += 1
        # ==============================
        report "  = CRÉATION Travail LOCAL ##{wid}"
      elsif loc_data != dis_data
        if loc_data[:updated_at] > dis_data[:updated_at]
          loc_data_sans_id = loc_data.dup
          loc_data_sans_id.delete(:id)
          # ======== ACTUALISATION =======
          dis_table.update(wid, loc_data_sans_id)
          @nombre_synchronisations += 1
          # ==============================
          report "  = UPDATE Travail DISTANT ##{wid}"
        else
          dis_data_sans_id = dis_data.dup
          dis_data_sans_id.delete(:id)
          # ======== ACTUALISATION =======
          loc_table.update(wid, dis_data_sans_id)
          @nombre_synchronisations += 1
          # ==============================
          report "  = UPDATE Travail LOCAL ##{wid}"
        end
      else
        # Deux travaux identiques => rien à faire
      end
    end
    report "  = Table 'travaux_analyses' synchronisée"
  end

  def synchronize_fichiers_analyses
    report "  * Synchronisation des fichiers d'analyse"
    sync_files './data/analyse', './www/data/analyse'
    report "  = Fichiers d'analyse synchronisés"
  end

  def db_suffix
    @db_suffix ||= :biblio
  end
end #/Filmodico
end #/Sync
