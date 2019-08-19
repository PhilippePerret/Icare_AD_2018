# encoding: UTF-8
=begin

Définition des données de synchro

PENSER À ACTUALISER CE FICHIER SI DES CHANGEMENT SONT FAITS car il
sert aussi ONLINE.

Pour utiliser ces données n'importe où, il faut :

    require './_objet/site/data_synchro.rb'

=end

# ---------------------------------------------------------------------
#   Serveur SSH à utiliser
#
# Il faut tout avoir régler pour pouvoir utiliser la commande SSH
# sans avoir à donner de mot de passe. Donc il faut avoir installé
# une clé d'authentification, etc.
# On doit pourvoir faire tout ça avec le Terminal pour une première
# utilisation.
# ---------------------------------------------------------------------
class Synchro
  SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net"
  # Retourne le serveur SSH
  # Attention, cette méthode est appelée aussi par la synchronisation
  # qui ne connait pas le site `site`.
  def serveur_ssh
    if respond_to?(:site)
      site.serveur_ssh || site.ssh_server || SERVEUR_SSH
    else
      SERVEUR_SSH
    end
  end


end

# ---------------------------------------------------------------------
#   Fichiers à ignorer
#
# Les dossiers doivent obligatoirement se terminer par "/" car c'est
# comme ça que l'on sait que l'élémnet qu'on traite est le dossier
# recherché.
#
# ACTUALISER CE FICHIER ONLINE APRÈS TOUTE MODIFICAITON pour être sûr
# que les fichiers écartés seront les mêmes.
# ---------------------------------------------------------------------
class Synchro
  def app_ignored_files
    [
      # Ici la liste des paths de fichiers à ignorer
      './_objet/actualite/listing_home.html'
    ]
  end
  def app_ignored_folders
    # Les dossiers doivent OBLIGATOIREMENT se terminer par "/"
    [
      './_lib/modules_optional/Synchronisation/',
      './LOCAL_CRON/',
      './_view/img/CHANTIER',
      './_lib/modules_optional/Links_analyzer/output/routes_msh/',
      './data/qdd'
    ]
  end
end

# ---------------------------------------------------------------------
#   Dossiers à checker et dans quel sens
#
# :dir détermine le type de check en s'appuyant sur la date de
# dernière modification du fichier.
#   Si :dir = :l2s (local-to-server), on doit seulement s'assurer que
#   le fichier online est au moins égal sinon plus vieux que le fichier
#   offline.
#   SI :dir = :s2l (server-to-local), c'est l'inverse
#

# ---------------------------------------------------------------------
class Synchro
  def folders_2_check
    {
      'CRON'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      '_lib'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      '_objet'    => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      '_view'     => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'data'      => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'hot'       => { extensions: COMMON_EXTENSIONS, dir: :l2s},
      'database'  => {extensions: ['db', 'rb'], dir: :l2s}
    }
  end
  def files_2_check
    {
      # './CRON/hour_cron.rb' => {dir: :both}
    #   './database/filmodico.db'   => {dir: :both},
    #   './database/cnarration.db'  => {dir: :both},
    #   './database/scenodico.db'   => {dir: :both},
    #   './'
    }
  end
end

# ---------------------------------------------------------------------
#   Différentes configurations dont a besoin la synchronisation
#
class Synchro

  def base
    @base ||= "http://localhost/AlwaysData/Icare_AD_2018/"
  end

  def app_name
    @app_name = "Icare_AD_2018"
    # @app_name = "Atelier Icare"
  end
  # Le dossier contenant les librairies javascript de
  # base (Ajax, jQuery, etc.)
  # Ce dossier doit contenir le dossier 'first_required' pour les
  # premiers JS requis et le dossier 'required' pour les autres
  # js requis
  def javascript_folder
    @javascript_folder ||= './js'
    # @javascript_folder ||= File.join('.', 'js')
  end
end
