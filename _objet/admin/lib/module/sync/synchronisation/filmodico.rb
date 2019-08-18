# encoding: UTF-8
class Sync
  def synchronize_filmodico
    @report << "* Synchronisation du FILMODICO"
    if Sync::Filmodico.instance.synchronize(self)
      @suivi << "= Synchronisation du FILMODICO OPÉRÉE AVEC SUCCÈS"
    else
      mess_err = "# ERREUR pendant la synchronisation du FILMODICO".in_span(class: 'warning')
      @report << mess_err
      @errors << mess_err
    end
  end
class Filmodico
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  # Méthode principale de synchronisation du Filmodico.
  # Le Filmodico doit être synchronisé de deux façons :
  #   - la base de donnée (table 'filmodico' dans :biblio)
  #   - les affiches de film (de local vers boa)
  #
  # Note : Maintenant, on ne synchronise plus sur Icare, car
  # tout est pris de Boa.
  #
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0
    synchronize_fiches_database
    synchronize_films_analyses
    synchronize_affiches
    if @nombre_synchronisations > 0
      report "  NOMBRE DE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation du FILMODICO OPÉRÉE AVEC SUCCÈS'
    end
  rescue Exception => e
    error e.message
    false
  else
    true
  end

  # Synchronisation des fiches dans la base de données.
  #
  # Rappel : C'est en ONLINE qu'on peut faire les modifications
  # donc si les fiches sont différentes, c'est toujours la table
  # local qu'on modifie.
  def synchronize_fiches_database
    report "  * Synchronisation des fiches dans les bases de données"
    self.table_name = 'filmodico'

    # Quelquefois, on doit actualiser en online une
    # fiche qui a été supprimée (suite à un problème, par exemple, on
    # peut détruire la fiche online)
    loc_rows.each do |fid, loc_data|
      dis_data = dis_rows[fid]
      if dis_data.nil?
        # => Il faut la créer
        # ==== ACTUALISATION ===========
          dis_table.insert(loc_data)
          @nombre_synchronisations += 1
        # ==============================
        report "    = (Re?)Création de la fiche ONLINE du film #{loc_data[:titre]}"
      end
    end

    # Les cas les plus fréquents : nouvelle fiche en online
    dis_rows.each do |fid, dis_data|
      loc_data = loc_rows[fid]

      if loc_data.nil?
        # La fiche du film n'existe pas localement
        # => Il faut la créer
        # ==== ACTUALISATION ===========
          loc_table.insert(dis_data)
          @nombre_synchronisations += 1
        # ==============================
        report "    = Création de la fiche du film #{dis_data[:titre]}"
      elsif dis_data != loc_data
        # Les fiches sont différentes
        # => Il faut actualiser la fiche locale
        # ======== ACTUALISATION =========
          dis_data.delete(:id)
          loc_table.update(fid, dis_data)
          @nombre_synchronisations += 1
        # =================================
        report "    = Modification de la fiche du film #{dis_data[:titre]}"
      else
        # Les deux fiches sont identiques
        suivi "Fiche film “#{dis_data[:titre].force_encoding('utf-8')}” OK"
      end
    end
    report "  = Synchronisation des fiches OK"
  end

  # Synchronisation des affiches
  def synchronize_affiches
    report "  * Synchronisation des affiches"
    loc_affiches_folder = "./#{Dom.folder_images}/affiches"
    dis_affiches_folder = "./www/#{Dom.folder_images}/affiches"
    sync_files loc_affiches_folder, dis_affiches_folder
    report "  = Synchronisation des affiches OK"
  end

  # Il faut également synchroniser la table des film
  def synchronize_films_analyses
    report "  * Synchronisation de la table 'films_analyses'"

    self.table_name = "films_analyses"

    dis_rows.each do |fid, dis_fdata|

      loc_fdata = loc_rows[fid]

      dis_fdata_sans_id = dis_fdata.dup
      dis_fdata_sans_id.delete(:id)
      unless loc_fdata.nil?
        loc_fdata_sans_id = loc_fdata.dup
        loc_fdata_sans_id.delete(:id)
      end


      if loc_fdata.nil?
        # Donnée inexistante sur le site distant (normalement,
        # ça ne devrait pas pouvoir exister)
        # => Créer la donnée sur le site distant
        # ============ ACTUALISATION =============
          loc_table.insert(dis_fdata)
          @nombre_synchronisations += 1
        # =========================================
        report "  * Création de la donnée film ##{fid} LOCALE (#{dis_fdata[:titre]})"
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
          report "  = Actualisation de la donnée DISTANTE ##{fid} (#{loc_fdata_sans_id[:titre]})"
        else
          # dis -> loc
          # ============ ACTUALISATION =============
            loc_table.update(fid, dis_fdata_sans_id)
            @nombre_synchronisations += 1
          # =========================================
          report "  = Actualisation de la donnée LOCALE ##{fid} (#{dis_fdata_sans_id[:titre]})"
        end
      else
        # Les deux données sont identiques => rien à faire
      end
    end
    report "  * Table 'films_analyses' synchronisée"
  end

  def db_suffix ; @db_suffix ||= :biblio        end
end #/Filmodico
end #/Sync
