# encoding: UTF-8
class Database
class << self

  # = main =
  #
  # Méthode principale pour comparer la table online avec la table
  # offline. Elle est appelée par le bouton 'Compare online/offine'
  # dans la section des gestions des bases de données.
  #
  def _compare_online_offline db_suffix, table_name
    resultats = Array.new
    resultats << "=== Comparaison online/offline #{Time.now} ==="
    resultats << "=== BASE  : #{site.prefix_databases}_#{db_suffix} "
    resultats << "=== TABLE : #{table_name}"
    resultats << ""
    table_online  = site.dbm_table(db_suffix, table_name, online = true)
    table_offline = site.dbm_table(db_suffix, table_name, online = false)

    rows_online   = table_online.select.as_hash_with_id
    rows_offline  = table_offline.select.as_hash_with_id

    rows_online.each do |row_id, row_online|
      row_offline = rows_offline[row_id]

      if row_offline.nil?
        resultats << "# La donnée online ##{row_id} n'existe pas en local."
      else
        if row_offline != row_online
          resultats << "* Rangée ##{row_id} différente online/offline."
        else
          resultats << "= Rangée ##{row_id} identique"
        end
      end
    end

    rows_offline.each do |row_id, row_offline|
      rows_online[row_id].nil? || next # déjà traité
      # On ne traite que les rangée offline qui n'existent pas, sinon,
      # elles ont déjà été traitées dans la boucle précédente
      resultats << "# La rangée offline ##{row_id} n'existe pas en distant."
    end

    resultats.join("\n")
  end

end #/<< self
end #/Database
