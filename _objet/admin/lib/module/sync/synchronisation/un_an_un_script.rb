# encoding: UTF-8
class Sync
  def synchronize_uaus
    @report << "* SYNCHRONISATION DU PROGRAMME ÉCRIRE EN UN AN"
    if UAUS.instance.synchronize(self)
      @suivi << "= Synchronisation du programme ÉCRIRE EN UN AN opéré avec SUCCÈS"
    else
      mess_err = "# PROBLÈME EN SYNCHRONISATION ÉCRIRE EN UN AN".in_span(class: 'warning')
      @report << mess_err
      @suivi << mess_err
    end
  end

class UAUS
  include Singleton
  include CommonSyncMethods

  def synchronize sync
    @sync = sync
    @nombre_synchronisations = 0
    synchronize_database
    synchronize_fichiers
    if @nombre_synchronisations > 0
      report "  = NOMBRE DE SYNCHRONISATIONS : #{@nombre_synchronisations}".in_span(class: 'blue bold')
      report '  = Synchronisation du programme ÉCRIRE EN UN AN opéré avec SUCCÈS'.in_span(class: 'blue bold')
    end
    true
  end

  # Méthode principale de synchronisation des données
  # des bases de données (à part les bases 'hot' que sont les
  # tables de programmes et de projets)
  def synchronize_database

    [
      'absolute_pdays',
      'absolute_works',
      'exemples',
      'pages_cours',
      'questions',
      'quiz'
    ].each do |table_name|
      @table_name = table_name
      reset

      report "  * Synchronisation de la table `#{table_name}` (#{loc_rows.count} rangées)"

      # On boucle sur toutes les rangées locales
      loc_rows.each do |rid, loc_data|
        dis_data = dis_rows.delete(rid)

        # suivi "Rangée ##{rid} : #{loc_data.inspect}"
        if dis_data.nil?
          # ==== SYNCHRONISATION ====
          dis_table.insert(loc_data)
          @nombre_synchronisations += 1
          # =========================
          report "    Création de la rangée distante ##{rid}"
        elsif loc_data != dis_data
          # ==== SYNCHRONISATION ====
          dis_table.update(rid, loc_data)
          @nombre_synchronisations += 1
          # =========================
          report "    Actualisation de la rangée distante ##{rid}"
        end

      end

      if dis_rows.count > 0
        report "    Rangées distantes à détruire : #{dis_rows.count}"
      else
        report "    Aucune rangée distante à détruire (OK)."
      end

      report "  = Synchronisation table #{table_name} OK\n"
    end

  end # / Fin de synchronisation des tables de données


  # Méthode principale qui procède à la synchronisation des
  # fichiers du programme ÉCRIRE EN UN AN
  def synchronize_fichiers
    report "* Synchronisation des fichiers physiques du programme"
    sync_files loc_folder_program, dis_folder_program
    report "= Synchronisation des fichiers physiques du programme OK"
  end

  def serveur_ssh
    @serveur_ssh ||= begin
      require './_objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end
  def loc_folder_program
    @loc_folder_program ||= './data/unan/pages_semidyn/program'
  end
  def dis_folder_program
    @dis_folder_program ||= './www/data/unan/pages_semidyn/program'
  end

  def db_suffix ; @db_suffix ||= :unan end
  def table_name; @table_name end
end #/UAUS
end #/Sync
