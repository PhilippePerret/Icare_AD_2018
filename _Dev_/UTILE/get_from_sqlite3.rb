# encoding: UTF-8
=begin

  Ce script doit fonctionner seul, depuis Atom ou TextMate, pour
  récupérer le contenu d'une table SQLite 3
=end

AFFIXE_BASE = 'hot_data'
# index_table = 0
#  # table par l'indice dans liste_tables
TABLE = 'watchers' # table par son nom

require 'sqlite3'

def dbase_old
  @dbase_old ||= begin
    pathold = "./xprev_version/db/#{AFFIXE_BASE}.db"
    dbase_old = SQLite3::Database.new(pathold)
  end
end

def list_tables
  @list_tables ||= begin
    request = 'SELECT name FROM sqlite_master WHERE type="table";'
    dbase_old.results_as_hash = true
    rows = dbase_old.execute(request).collect
    arr = Array.new
    puts "\n === LISTE DES TABLES ==="
    rows.each do |hdata|
      next if ['__column_names__', 'sqlite_sequence'].include?(hdata['name'])
      arr << hdata['name']
      puts "TABLE #{hdata['name']}"
    end
    puts "\n\n\n"
    arr
  end
end

# Pour obtenir la liste des table
# list_tables

defined?(TABLE) || TABLE = list_tables[index_table]

request = "SELECT * FROM #{TABLE};"
puts "request : #{request}"

dbase_old.results_as_hash = true
rows = dbase_old.execute(request).collect

# On récupère les longueurs de colonnes pour faire un affichage
column_list_done = false
colonnes = Hash.new
new_rows = Array.new
rows.each do |hdata|
  new_rows << hdata
  hdata.each do |k, v|
    next if k.instance_of?(Fixnum)
    column_list_done || begin
      puts "Ajout de colonne : #{k.inspect}"
      colonnes.merge!(k => {name: k, max: k.to_s.length + 1})
    end
    v.to_s.length < colonnes[k][:max] || colonnes[k][:max] = v.to_s.length
  end
  column_list_done = true
end

rows = new_rows

# On construit la première rangée
first_row =
  colonnes.collect do |k, dk|
    k.to_s.ljust(dk[:max])
  end.join(' | ')

first_row = "| #{first_row} |"
row_width = first_row.length
separator = "-"*row_width

puts "\n=== LISTE DES DONNÉES DE LA TABLE #{TABLE} ==="
puts separator
puts first_row
puts separator

# On fait enfin l'affichage
rows.each do |hdata|
  arr = Array.new
  next if hdata['processus'] == 'icarien/current_etape/envoi_travail'
  next if hdata['processus'] == 'icarien/current_module/paiement'
  next if [9,75, 83].include?(hdata['user_id'])

  hdata.each do |k, v|
    next if k.instance_of?(Fixnum)
    # Les rangées à passer
    arr << v.to_s.gsub(/\n/,'\\n').ljust(colonnes[k][:max])
  end
  puts "| " + arr.join(" | ") + " |"
end
