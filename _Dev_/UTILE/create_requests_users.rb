#!/usr/bin/env ruby

# 12:45 Samedi 1er octobre
# class Fixnum;
#   def days; self * 24 * 3600 end
#   def hours; self * 3600 end
# end
#
# # c = 11👍👎 → ⇥ ⇤ ✅ ❏ ◽️ ☑️ 🌀 ←➖🗑🔨🔧📓✏️⛔️🚫➕
# # 🗃 ⚠️🔔📎⭕️❌✅👓🕶🚧📌📍
# # ⬋⬉⬈➘ ⁊∟ ‾⎽
# # ¶

                # - 30 000      + 30 000
#ID    PSEUDO    CREATED_AT    UPDATED_AT    ICMODULE_ID   LAST_ETAPE
DATA = <<-EOT
33    Muse98    1270731269    1273928542    12            58
66    Ptachka   1294477906    1294477911    15            104
71    Gabriela  1439970069    1440315669    8             36
EOT

data = DATA.split("\n").collect{|l| l.gsub(/[\t ]+/,"\t").split("\t")}

arr_users = Array.new

data.each do |row|
  goodrow = Array.new
  row.each_with_index do |e, i|
    goodrow << (i == 1 ? e.to_s : e.to_i)
  end
  id, pseudo, created_at, updated_at, icmodule_id, icetape_id = goodrow
  created_at = created_at - 30000
  updated_at = updated_at + 30000
  user = {id: id, pseudo: pseudo, created_at: created_at, updated_at: updated_at, icmodule_id: icmodule_id, icetape_id: icetape_id}
  arr_users << user
end


requests = arr_users.collect do |u|
  options = '00100000000000004000000811100000'
  options[3]  = '1' # détruit
  options[4]  = '9' # aucun mail
  options[16] = '4' # inactif
  options[17] = '1' # jamais de mail d'actualité
  options[19] = '8' # aucun contact
  options[21] = '0' # ne partage pas son historique
  options[22] = '0' # aucune notification quand message
  options[23] = '8' # aucun contact avec le reste du monde
  <<~SQL
  INSERT INTO users SET 
    id = #{u[:id]}, 
    pseudo = '#{u[:pseudo]} (SUPP)', 
    mail = 'phil@atelier-icare.net',
    sexe = 'F',
    options = #{options},
    naissance = 1984,
    created_at = #{u[:created_at]}, 
    updated_at = #{u[:updated_at]},
    date_sortie = #{u[:updated_at]}
    ;
  SQL
end

requests = requests.collect{|e| e.gsub(/\n/,'').gsub(/\t/,' ').gsub(/  +/,' ')}

puts requests.join("\n")