# encoding: UTF-8
#
# Mettre ONLY_REQUIRE à true dans le module appelant pour ne faire
# que requérir cette librairie, sans lancer le préambule.
#
# Méthodes qu'on peut utiliser au chargement (avant que les
# librairies de débug soient en place) pour laisser des messages
# de débug.
#
# @usage      main_safed_log <message>
#
# Il faut ensuite aller charger le fichier ./safed.log par
# FTP
timein = Time.now.to_f
def main_safed_log mess
  main_ref_log.puts mess
end
def main_ref_log
  @main_ref_log ||= File.open(main_safe_log_path, 'a')
end
def main_safe_log_path
  @main_safe_log_path ||= "./safed.log"
end


# ONLY_REQUIRE est définie pour essayer de ne faire que
# charger les modules par le Terminal, sinon on se
# retrouve avec CGI qui attend des pairs de variable
defined?(ONLY_REQUIRE) || ONLY_REQUIRE = false

defined?(ONLINE) || begin
  ONLINE  = ENV['HTTP_HOST'] != "localhost"
  OFFLINE = !ONLINE
end

# Pour sasser les fichiers en OFFLINE
if OFFLINE
  require './_Dev_/sass_all'
end

def require_folder dossier
  # main_safed_log "Require dossier #{dossier}"
  Dir["#{dossier}/**/*.rb"].each do |m|
    # main_safed_log "Module : #{m}"
    require m
  end
end

# On essaie ça : si on est ONLINE, on met tous les dossier GEMS
# de ../.gems/gems en path par défaut, ainsi, tous les gems
# seront accessibles
# if ONLINE
#   Dir["../.gems/gems/*"].each do |fpath|
#     $LOAD_PATH << "#{fpath}/lib"
#   end
# end



# On peut maintenant requérir tous les gems
=begin
raise <<-EOC
<pre><code>
RUBY_VERSION : #{RUBY_VERSION}
$> ruby --version
# => #{`ruby --version`}
$> which -a ruby
# => #{`which -a ruby`}
</code></pre>
EOC
=end
def raise_with_ruby mess
  raise <<-EOC
  <pre><code>
  ERROR : #{mess}

  #{`gem env`}
  </code></pre>
  EOC
end
require 'rubygems'
require 'singleton'
begin
  require 'mysql2'
rescue Exception => e
  raise_with_ruby "Erreur avec require mysql2 : #{e.message}"
end
require 'json'

# On requiert tous les modules utiles
require_folder './_lib/modules_common'
require_folder './_lib/_required'

site.require_gem 'superfile'
# defined?(SuperFile)|| raise("La class SuperFile n'est pas définie.")

# Le site
require_folder './_objet/site/lib/required'


site.require_config
app.require_config

User.init # charge les librairies du dossier objet/user

# ---------------------------------------------------------------------
#   Quelques initialisations et vérification
# ---------------------------------------------------------------------

ONLY_REQUIRE || begin
  if site.ajax?
    site.require_module('Ajax')
  else
    require './_lib/preambule'
    execute_preambule
  end
end
app.benchmark('-> required.rb', timein)
app.benchmark('<- required.rb')
