# encoding: UTF-8
=begin

  (le plus simple pour ces méthodes est de les copier en bas de
   site/home.rb et de charger la page d'accueil)
   
  Pour récupérer les données de sqlite3 vers MySQL pour la
  version de l'atelier MARION 2016

  Il faut jouer ce script en console avec :

    run db_post_version_marion2016

  Après avoir décocher les modules à jouer.

=end

# # Récupération des données absolues des modules
# # OK Donc doit être devenu inutile
# require './_Dev_/to_version_2016/abs_modules.rb'

# # Récupération des données absolues des étapes
# # OK Donc doit être devenu inutile
# require './_Dev_/to_version_2016/abs_etapes.rb'

# # Récupération des travaux-type
# # OK donc ne doit plus servir
# require './_Dev_/to_version_2016/abs_travaux_type.rb'

# Récupération des users
# Actualiser le fichier ./xprev_version/db/icariens.db en le
# prenant online et décommenter la ligne suivante pour actualiser
# tous les utilisateurs.
# require './_Dev_/to_version_2016/users.rb'

# # Récupération des données des IC-MODULES
# require './_Dev_/to_version_2016/ic_modules.rb'

# # Récupération des données des IC-ETAPES
# require './_Dev_/to_version_2016/ic_etapes.rb'

# # Récupération des données des DOCUMENTS
# require './_Dev_/to_version_2016/ic_documents.rb'

# Récupération des données des paiements
# Dans le fichier `archives.db`
# require './_Dev_/to_version_2016/paiements.rb'

# Récupération des données de la minifaq
# require './_Dev_/to_version_2016/mini_faq.rb'

# Récupération des témoignages
# Normalement, il n'y a plus à le faire, c'est fait.
# require './_Dev_/to_version_2016/temoignages.rb'
