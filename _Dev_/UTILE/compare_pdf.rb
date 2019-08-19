# encoding: UTF-8
=begin
Pour comparer le contenu des dossiers pdfs
=end
puts 'Folder courant : ' + File.expand_path('.')
ONLY_REQUIRE = true
require './_lib/required'
#
folder_dst = site.folder_data+'qdd/pdfs'
folder_src = site.folder_app+'xprev_version/qdd/pdfs'

folder_dst.exist? || (raise 'Le dossier de destination n’existe pas')
puts "- Le dossier destination existe."
folder_src.exist? || (raise "Le dossier source (#{folder_src}) n'existe pas.")
puts "- Le dossier source existe."

puts "=== Comparaison des dossiers ==="
oks = Array.new
not_oks = Array.new
Dir["#{folder_src}/**/*.pdf"].each do |fpath|
  fname = File.basename(fpath)
  ffolder = File.dirname(fpath)
  mod_id = File.basename(ffolder)

  folder_in_dst = folder_dst + "#{mod_id}"

  fdest = folder_in_dst + fname
  # puts "test de #{fdest}…"
  if fdest.exist?
    # puts "-> connu"
    oks << fdest
  else
    # puts "-> inconnu"
    not_oks << fdest
  end
  # sleep 0.2
end

puts "\n= FICHIERS INCONNUS =\n"
puts not_oks.collect{|f| f.to_s}.join("\n")

puts "\n= FICHIERS CONNUS =\n"
puts oks.collect{|f| f.to_s}.join("\n")
