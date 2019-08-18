# encoding: UTF-8
=begin

  Module de synchronisation de la collection Narration.
  Cette synchronisation joue sur deux choses :
    - les données de la base `boite-a-outils_cnarration`
    - les fichiers physiques des livres

=end
class Sync

  def synchronize_narration
    @report << "* Synchronisation IMMÉDIATE de la Collection NARRATION"
    if Sync::CNarration.instance.synchronize(self)
      @suivi << "= Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS"
    else
      @report << "# PROBLÈME AVEC LA SYNCHRONISATION DE LA COLLECTION NARRATION".in_span(class: 'red')
    end
  end

class CNarration
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  # Méthode principale de la synchronisation de la collection Narration.
  # - au niveau de la base de données
  # - au niveau des fichiers à synchroniser
  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0

    # Syncrhonisation des données des pages et
    # chapitre/sous-chapitre de la collection
    synchronize_database

    # Synchronisation des données de tables des
    # matières de la collection narration
    nb_sync = Sync::TDMNarration.instance.synchronize(sync)
    @nombre_synchronisations += nb_sync

    # Synchronisation des fichiers physiques de la
    # collection.
    synchronize_fichiers

    if @nombre_synchronisations > 0
      report "  NOMBRE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class:'blue bold')
      report '  = Synchronisation de la collection Narration OPÉRÉE AVEC SUCCÈS'.in_span(class:'blue bold')
    end
  rescue Exception => e
    debug e
    self.error "# PROBLÈME SYNCHRO NARRATION : #{e.message}"
    false
  else
    true
  end

  def synchronize_database

    report "* Synchronisation des données de database"
    report "Nombre de rangées locales   : #{loc_rows.count}"
    report "Nombre de rangées distantes : #{dis_rows.count}"

    # Boucle sur chaque page locale
    # Note : Puisque les pages ne peuvent être que créées localement,
    # il est inutile de vérifier les pages distantes.
    loc_rows.each do |pid, loc_data|
      dis_data = dis_rows[pid]

      # debug "loc_data: #{loc_data.inspect}"
      # debug "dis_data: #{dis_data.inspect}"

      if dis_data.nil?
        # C'est la création d'une nouvelle page en local
        # ======== ACTUALISATION =======
        dis_table.insert(loc_data)
        @nombre_synchronisations += 1
        # ==============================
        report "CRÉATION de la page (ou titre) DISTANT : #{loc_data.inspect}"
      elsif loc_data != dis_data
        # Données différentes
        # Si c'est le niveau de développement qui a changé, il faut
        # updater le niveau le plus bas.
        # Si c'est une autre donnée qui a changé, il faut prendre
        # l'updated_at pour voir la plus récente (et signaler quand même
        # un problème si c'est en online que la modification est la plus
        # récente, ce qui ne devrait pas vraiment arriver)
        if loc_data[:options][1] != dis_data[:options][1]
          debug "NIV DEV DIFFÉRENT (#{loc_data[:options]} / #{dis_data[:options]})"
          # NIVEAU DE DÉVELOPPEMENT DIFFÉRENT
          loc_data = update_niveau_developpement(pid, loc_data, dis_data)
          debug "loc_data après : #{loc_data.inspect}"
          @nombre_synchronisations += 1
        end
        # Autre donnée différente. Dans ce cas, on prend
        # la date de dernière modification pour savoir quelle
        # donnée doit être actualisée
        loc_plus_jeune          = loc_data[:udpated_at].to_i > dis_data[:updated_at].to_i
        loc_priorite_plus_jeune = loc_data[:options].length > dis_data[:options].length
        if loc_plus_jeune || loc_priorite_plus_jeune
          # OK => actualisation de la donnée distante
          debug "dis_table actualisée pour ##{loc_data[:id]}"
          dis_table.update(pid, loc_data)
          @nombre_synchronisations += 1
        end
        #   # Actualisation de la donnée locale, mais attention,
        #   # c'est bizarre puisqu'on ne devrait pas modifier les
        #   # données en distant.
        #   loc_table.update(pid, dis_data)
        #   @nombre_synchronisations += 1
        # end
      else
        suivi "Pages ##{pid} loc/dis identifiques"
      end
    end
  end

  def synchronize_fichiers
    report "* Synchronisation des fichiers physiques"
    sync_files loc_cnarration_folder, dis_cnarration_folder
    report "= Synchronisation des fichiers physiques OK"
  end

  # ---------------------------------------------------------------------
  #   SOUS-MÉTHODES DE SYNCHRONISATION
  # ---------------------------------------------------------------------

  # Actualisation d'un fichier ERB distant
  #
  def upload_narration_file relpath
    loc_fullpath = "#{loc_cnarration_folder}/#{relpath}"
    dis_fullpath = "#{dis_cnarration_folder}/#{relpath}"
    retour = upload_file loc_fullpath, dis_fullpath
  end

  # Dossier narration local
  def loc_cnarration_folder
    @loc_cnarration_folder ||= './data/unan/pages_semidyn/cnarration'
  end

  # Dossier narration distant
  def dis_cnarration_folder
    @dis_cnarration_folder ||= './www/data/unan/pages_semidyn/cnarration'
  end

  # ---------------------------------------------------------------------
  #   SOUS MÉTHODES
  # ---------------------------------------------------------------------

  # Pour actualiser le niveau de développement d'une page
  #
  # Retourne la donnée locale actualisée
  def update_niveau_developpement(pid, loc_data, dis_data)
    loc_niv = loc_data[:options][1].to_i(11)
    dis_niv = dis_data[:options][1].to_i(11)
    good_niv = loc_niv > dis_niv ? loc_niv : dis_niv

    loc_data[:options][1] = good_niv.to_s(11)
    dis_data[:options][1] = good_niv.to_s(11)

    if loc_niv > dis_niv
      dis_table.update(pid, {options: dis_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{loc_niv}"
    else
      loc_table.update(pid, {options: loc_data[:options]})
      report "Niveau de développement de ##{pid} passé à #{dis_niv}"
    end
    return loc_data
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'narration' end

end #/CNarration

# Pour la table 'tdms'
# Usage Sync::TDMNarration.instance.loc_table ou dis_table, etc.
class TDMNarration
  include Singleton
  include CommonSyncMethods

  # Retourne le nombre de synchronisations
  def synchronize sync
    @sync = sync

    nombre_synchronisations = 0

    loc_rows.each do |rid, loc_data|
      dis_data = dis_rows[rid]
      # suivi "#{loc_data.inspect} / #{dis_data.inspect}"
      if loc_data != dis_data
        if dis_data[:updated_at] > loc_data[:updated_at]
          dis_data.delete(:id)
          loc_table.update(rid, dis_data)
        else
          loc_data.delete(:id)
          dis_table.update(rid, loc_data)
        end
        nombre_synchronisations += 1
      else
        # Les deux données sont identiques, rien à faire
      end
    end

    return nombre_synchronisations
  end

  def db_suffix   ; @db_suffix  ||= :cnarration end
  def table_name  ; @table_name ||= 'tdms'      end
end #/TDMNarration
end #/Sync
