# encoding: UTF-8
=begin

Ce module permet de checker l'état de synchronisation entre le site local
et le site sur serveur.

Il est utilisé aussi bien localement que sur le serveur pour récolter les
données.

UTILISATION

    Runner simplement ce script.

=end
MODE_SERVEUR = false unless defined?(MODE_SERVEUR)

require_relative 'synchronisation/required'


isynchro = Synchro::new

if MODE_SERVEUR
  ##
  ## ONLINE
  ##
  ## Le programme passe par ici quand le script est joué sur le serveur
  ## pour récupérer les informations des fichiers sur le serveur.
  ##
  isynchro.check_folders
  # On écrit le résultat en sortie pour qu'il soit transmis en
  # local.
  puts Marshal::dump( isynchro.result )
else
  ##
  ## OFFLINE
  ##
  isynchro.check_synchro
end
