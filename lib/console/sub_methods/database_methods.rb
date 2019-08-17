# encoding: UTF-8
=begin

  show_table <{BdD::Table} table>

  La méthode `show_table` se trouve dans le fichier
    ./lib/deep/deeper/module/console/table.rb

=end
raise_unless_admin

class SiteHtml
class Admin
class Console

  # Retourne un array contenant la base de données ({BdD}) et la table
  # ({BdD::Table}) pour un +last_word+ qui ressemble à "path/to/db.latable"
  # Produit les erreurs si problème et retourne nil
  def db_path_and_table_from_last_word last_word
    path, table = last_word.split('.')
    raise "Il faut définir le nom de la table dans la requête." if table.nil?
    full_path = SuperFile::new("./database/data/#{path}.db")
    raise "La base de données `#{full_path}` n'existe pas…" unless full_path.exist?
    bdd = BdD.new(full_path.to_s)
    tbl = ( bdd.table table )
    raise "La table `#{table}` n'existe pas dans la base de données spécifiée (dont l'existence a été vérifiée)" unless bdd.table(table).exist?
    return [bdd, tbl]
  rescue Exception => e
    sub_log "`#{last_word}` est invalide.\n" +
      "Expected : path/to/db/depuis/database/data/sans/db DOT nom_table\n"+
      "Example  : `show table forum.posts`\n" +
      "Pour     : la table `posts` dans la db `./database/data/forum.db`."

    ["# ERROR: #{e.message}", nil]
  end

  # Détruit définitivement la table
  # Par mesure de prudence, une copie est fait de la base originale,
  # mise dans le dossier temporaire
  def destroy_table_of_database last_word
    sub_log "Destruction de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    dest_path = (site.folder_tmp + "#{bdd.name}-prov.db")
    dest_path.remove if dest_path.exist?
    FileUtils::cp bdd.path, dest_path
    tbl.remove
    if tbl.exist?
      "ERROR : Table non détruite"
    else
      sub_log "<br>Copie de : `#{bdd.path}`"
      sub_log "<br>Dans : `#{dest_path}`"
      "Table détruite avec succès"
    end
  end

  # Vide (sans la détruire )
  def vide_table_of_database last_word
    sub_log "Vidage (sans destruction) de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    tbl.pour_away
    ""
  end

  def affiche_table_of_database last_word
    sub_log "Affichage de la table : #{last_word}"
    bdd, tbl = db_path_and_table_from_last_word last_word
    return bdd if tbl.nil?
    show_table tbl
  end


end #/Console
end #/Admin
end #/SiteHtml

=begin
=end
