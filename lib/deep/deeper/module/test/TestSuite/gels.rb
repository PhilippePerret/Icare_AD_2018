# encoding: UTF-8
=begin

  Module se chargeant des gels et autres backups

=end
class SiteHtml
class TestSuite

  class << self

    # Raccourci
    def log mess; console.sub_log "#{mess}\n" end

    # Liste des bases de données à traiter quand on
    # veut vérifier certaines choses.
    MAP_TABLES_TO_CHECK = {
      forum: [
        {dbpath: 'forum.db', tables: ['posts']}
      ]
    }

    # Méthode qui regarde les base de données obtenues à la
    # fin des tests
    #
    # Rappel : On peut appeler cette méthode en jouant la commande
    # `test show db`
    def display_db_after_test options = nil
      log '<pre style="font-size:13pt">'
      log "=== Bases de données à la fin des tests ==="
      log(
        Dir["#{folder_db_after_test}/**/*.db"].collect do |pdb|
          prel = pdb.sub(/^#{folder_db_after_test}\//o,'')
          "  - #{prel}"
        end.join("\n")
        )
      log '</pre>'

      [
        ['forum.db' ,   ['posts', 'posts_content']],
      ].each do |pair|
        db_name, tables = pair
        tables.in_array.each do |table_name|
          inspect_db_table db_name, table_name
        end
      end
    end

    def inspect_db_table db_name, table_name
      log "TABLE #{table_name} DE #{db_name}".in_h4
      db_path = "#{folder_db_after_test}/#{db_name}"
      console.show_table( BdD::new(db_path).table(table_name) ) rescue nil
    end

    # Path du dossier contenant les bases de données telles
    # qu'elles ont été affectées par les tests joués.
    def folder_db_after_test
      @folder_db_after_test ||= './tmp/db_on_fin_tests/data'
    end

  end #/<<self

  # Fait une copie des bases de données actuelles pour
  # pouvoir les remettre une fois les tests terminés.
  #
  # La méthode met la variable d'instance @freezed à
  # true si l'opération s'est bien passée.
  def freeze_current_db_state
    start_time = Time.now
    src = "./database/data"
    dst = "./tmp/testdbbackdup"
    FileUtils::rm_rf(dst) if File.exist?(dst)
    `mkdir -p "#{dst}"`
    FileUtils::cp_r src, dst, {preserve: true}
    File.exist?("#{dst}/data") || raise( "Le dossier des backups des bases de données devrait exister.")
    @freezed = true
    end_time = Time.now
    infos[:duree_db_backup] = (end_time - start_time).round(3)
  end

  # À la fin des tests, on fait une copie
  # des bases de données pour pouvoir contrôler les
  # valeurs.
  #
  # Rappel : Il suffit de jouer `test show db` dans la console
  # pour afficher intégralement le contenu de toutes les
  # bases de données 'hot'
  #
  def backup_db_fin_test
    src = './database/data'
    dst = './tmp/db_on_fin_tests'
    FileUtils::rm_rf(dst) if File.exist?(dst)
    `mkdir -p "#{dst}"`
    FileUtils::cp_r src, dst, {preserve: true}
    File.exist?(self.class.folder_db_after_test) || raise("Le dossier des bases de données à la fin des tests devrait exister…")
  end


  # Remet les bases dans l'état où elles étaient avant
  # les tests
  # La méthode met la variable d'instance @unfreezed à true
  # si l'opération s'est bien passée.
  def unfreeze_current_db_state
    start_time = Time.now
    src = "./tmp/testdbbackdup/data"
    dst = "./database"
    dst_folder = "#{dst}/data"
    FileUtils::rm_rf(dst_folder) if File.exist?(dst_folder)
    FileUtils::cp_r src, dst, {preserve: true}
    File.exist?(dst_folder) || raise("Le dossier ./database/data devrait exister. Le récupérer dans le dossier `#{src}`.")
    # Pour indiquer que le dégel a eu lieu
    @unfreezed = true
    end_time = Time.now
    duree_freeze = (end_time - start_time).round(3)
    infos[:duree_db_unbackup] = (end_time - start_time).round(3)
  end

end #/TestSuite
end #/SiteHtml
