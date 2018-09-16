# encoding: UTF-8
class Sync

  # Méthode appelée par le programme principal pour
  # synchroniser les tâches.
  #
  # La synchronisation des tâches consiste à passer en revue
  # les tâches distantes et les tâches locales en synchronisant
  # les modifications, qui peuvent avoir eu lieu en online comme
  # en offline.
  #
  def synchronize_taches
    @suivi << "* Synchronisation des tâches"
    @report << "* Synchronisation immédiate des TÂCHES"
    if HotTaches.instance.synchronize(self)
      @suivi << "= Synchronisation des TÂCHES OPÉRÉE AVEC SUCCÈS"
    else
      mess_err = "# Synchronisation des tâches impossible"
      @suivi << mess_err
      @errors << mess_err
    end
  end

class HotTaches
  include Singleton
  include CommonSyncMethods

  # = main =
  #
  def synchronize(sync)
    @sync = sync

    nombre_synchronisations = 0

    loc_hot_taches = loc_rows(main_key: :created_at)
    dis_hot_taches = dis_rows(main_key: :created_at)

    report "Nombre de tâches HOT locales  : #{loc_hot_taches.count}"
    report "Nombre de tâches HOT distantes: #{dis_hot_taches.count}"


    loc_hot_taches.each do |ctime, loc_htache|
      dis_htache = dis_hot_taches.delete(ctime)

      # Pour comparer les données ainsi que pour les insérer
      # dans les tables, il ne faut pas tenir compte de l'identifiant
      # qui peut être différent entre la table locale et la table
      # distante.
      loc_htache_sans_id = loc_htache.dup
      loc_htache_sans_id.delete(:id)
      loc_extrait = loc_htache[:tache].strip_tags[0..80]

      unless dis_htache.nil?
        dis_htache_sans_id = dis_htache.dup
        dis_htache_sans_id.delete(:id)
        dis_tid = dis_htache[:id]
      end

      # Identifiant de la tâche hot locale
      # Attention : cet identifiant n'est pas forcément le
      # même que celui de la tâche distante, c'est la raison
      # pour laquelle on se sert de created_at comme clé
      # principale.
      loc_tid = loc_htache[:id]

      # Cas 1 : La tache distante n'existe pas
      if dis_htache.nil?
        suivi "Tache #{ctime} (##{loc_tid}) n'existe pas en HOT distant (finie ou nouvelle ?)."
        if is_tache_cold_distante?( ctime )
          suivi "Elle a été finie en distant"
          # Cas 1.1   C'est une tâche finie en distant
          #     => Il faut la finir en local
          # ================ ACTUALISATION ======================
          loc_table.delete(loc_tid)
          Sync::ColdTaches.instance.loc_table.insert(loc_htache_sans_id)
          nombre_synchronisations += 1
          # =====================================================
          report "Fin de tâche HOT ##{loc_tid} en local (#{loc_extrait})"
        else
          suivi "C'est une nouvelle tache locale"
          # Cas 1.2   C'est une nouvelle tache locale
          #     => Il faut l'ajouter en distant
          # ========= ACTUALISATION ============
          dis_table.insert(loc_htache_sans_id)
          nombre_synchronisations += 1
          # =====================================
          report "Ajout de tâche HOT ##{loc_tid} dans table distante (#{loc_extrait})"
        end

      else
        # Cas 2 : La tache distante existe
        if loc_htache_sans_id == dis_htache_sans_id
          # Cas 2.1 La tâche distante a les mêmes données => rien à faire
        else
          # Cas 2.2 La tache distante n'a pas les mêmes données
          #   => On regarde le :updated_at pour savoir quelle tâche est
          #      la plus à jour.
          if loc_htache[:updated_at] >= dis_htache[:updated_at]
            # Tâche locale modifiée plus récemment que tâche distante
            # =============== MODIFICATION ===============
            dis_table.update(dis_tid, loc_htache_sans_id)
            nombre_synchronisations += 1
            # ============================================
            report "Update de tâche hot distante ##{dis_tid} (#{loc_extrait})"
          else
            # Tâche distante modifiée plus récemment que tâche locale
            # =============== MODIFICATION ===============
            loc_table.update(loc_tid, dis_htache_sans_id)
            nombre_synchronisations += 1
            # ============================================
            report "Update de tâche hot locale ##{loc_tid} (#{loc_extrait})"
          end
        end
      end
    end #/ fin de boucle sur toutes les tâches hot locales

    # Boucle sur toutes les tâches hot distantes qui restent
    # Noter qu'on a retiré ci-dessus toutes celles qui correspondaient
    # à des tâches locales
    suivi "Nombre de hot tâches distantes restant à traiter: #{dis_hot_taches.count}"
    dis_hot_taches.each do |ctime, dis_htache|

      dis_tid = dis_htache[:id]

      # Hash sans identifiant
      dis_htache_sans_id = dis_htache.dup
      dis_htache_sans_id.delete(:id)

      dis_extrait = dis_htache[:tache].strip_tags[0..80]

      suivi "* Traitement tâche HOT DISTANTE #{ctime} (##{dis_tid}) inconnue localement (#{dis_htache[:tache][0..50]})"

      if is_tache_cold_locale?(ctime)
        # Tâche finie localement
        #   => La finir online
        # ======================== MODIFICATION ======================
        dis_table.delete(dis_tid)
        Sync::ColdTaches.instance.dis_table.insert(dis_htache_sans_id)
        nombre_synchronisations += 1
        # ============================================================
        report "Tâche distante ##{dis_tid} finie (#{dis_extrait})"
      else
        # Nouvelle tâche distante à ajouter en local
        # =========== MODIFICATION ==========
        loc_table.insert(dis_htache_sans_id)
        nombre_synchronisations += 1
        # ===================================
        report "Tâche distante ##{dis_tid} ajoutée en local (#{dis_extrait})"

      end

    end # / fin de boucle sur les tâches distantes restantes

    if nombre_synchronisations > 0
      report "NOMBRE SYNCHRONISATIONS : #{nombre_synchronisations}".in_span(class: 'blue bold')
      report '= Synchronisation des TÂCHES OPÉRÉE AVEC SUCCÈS'.in_span(class: 'blue bold')
    end
  rescue Exception => e
  else
    true
  end

  # Méthode qui retourne true si la tache de date de
  # création +ctime+ est une donnée cold distante
  def is_tache_cold_distante? ctime
    @taches_cold_distantes ||= begin
      Sync::ColdTaches.instance.dis_rows(main_key: :created_at, colonnes: [:id, :created_at])
    end
    return @taches_cold_distantes.key?(ctime)
  end

  # Retourne TRUE si la tâche de created_at +ctime+ est une
  # tâche localement terminée.
  def is_tache_cold_locale? ctime
    @taches_cold_locales ||= begin
      Sync::ColdTaches.instance.loc_rows(main_key: :created_at, colonnes: [:id, :created_at])
    end
    return @taches_cold_locales.key?(ctime)
  end

  def db_suffix   ; @db_prefix  ||= :hot      end
  def table_name  ; @table_name ||= 'taches'  end
end #/HotTaches

class ColdTaches
  include Singleton
  include CommonSyncMethods

  def db_suffix   ; @db_prefix  ||= :cold     end
  def table_name  ; @table_name ||= 'taches'  end
end #/ColdTaches

end #/Sync
