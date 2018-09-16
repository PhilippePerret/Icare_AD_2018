# encoding: UTF-8

# Les routes qui ne seront pas analysées
#
# Mettre à nil si aucune route n'est à exclure
#
EXCLUDED_ROUTES = {
  'manuel/home?in=analyse&operation=charger_manuel_femme' => true,
  'manuel/home?in=analyse&operation=charger_manuel_homme' => true,
  'aide/home?in=unan&operation=charger_manuel_femme'      => true,
  'aide/home?in=unan&operation=charger_manuel_homme'      => true
}

# Le test est fait sur File.dirname(route). Si c'est une clé de
# EXCLUDED_FOLDERS, on n'étudie pas la route.
# Si :check_status est à true, on vérifiera que l'appel de la page
# retourne quand même 200 (donc que la page se charge bien)
EXCLUDED_FOLDERS = {
  './data/analyse/films_tm' => {check_status: true}
}

# Cette table permet de définir tout un tas de chose par rapport aux
# routes à tester.
DATA_ROUTES = {
  # À faire si le contexte de la route est…
  context: {
    'cnarration' => {
      # Si le contexte de la route (attribut `in`) est 'cnarration', on
      # ajoute 'authips=1' à l'url appelée pour permettre une authentification
      # par l'IP juste sur ces pages.
      add_to_data_url: 'authips=1'
    }
  },
  objet: {
    # Quand l'objet — le premier mot de la route — est 'analyse'
    'analyse' => {
      add_to_data_url: 'authips=1',
      has_tags: [
        ['h1', {text: 'Les Analyses de films'}]
      ]
    }
  }
}

# Option ligne command : -v/--verbose
VERBOSE = false

# Pour tester le programme, limiter le nombre de routes
# testées
# Mettre à NIL pour les tester toutes.
#
# Option ligne de commande : -m/--max-routes
NOMBRE_MAX_ROUTES_TESTED = nil

# Format de sortie
# ----------------
# Peut être :
#   :html     Un fichier HTML produit, le plus pratique, avec
#             les styles et les liens permettant d'ouvrir les
#             routes et autres
#
# Option de ligne de commande : -f=.../--report-format
REPORT_FORMAT = :html

# Browser avec lequel il faut ouvrir le rapport
#
# Noter qu'il vaut mieux un browser où l'user n'est pas
# identifié, car certaines erreurs viennent de là
#
# Browser possible :
#  'Opera', 'Firefox', 'Safari', 'Google Chrome'
BROWSER_APP = 'Opera'

# Pour tester online ou offline
#
# Option de ligne de commande : -o/--online
TEST_ONLINE = false # false => test local

# Mettre à TRUE pour que la boucle s'interrompe à la première
# erreur rencontrée
#
# Option de ligne de commande : --fail-fast
FAIL_FAST = false

# Profondeur maximale
#
# Mettre à nil pour traiter toutes les profondeurs, donc absolument
# tous les liens.
#
# Si la profondeur est de 1, seuls les liens de la page définie
# par FROM_ROUTE (cf. ci-desous) seront traités.
#
# Option de ligne de commande : -d=…/--depth=…
DEPTH_MAX = nil

# Mettre à TRUE pour voir les routes collectées sur chaque page au
# fil de l'analyse
#
# Option de ligne de commande : -i/--infos
SHOW_ROUTES_ON_TESTING = false

# Route de démarrage du test
#
# Par défaut, c'est 'site/home'
#
# Pour essayer une unique route, par exemple une route qui pose problème
# Mais penser qu'il faut indiquer ici la route de la page qui contient
# le lien qui pose problème, pas le lien lui-même.
# Par exemple, en créant ce test, la route http://www.laboiteaoutilsdelauteur.fr
# posait problème — oui, je sais, un comble — mais c'est la page
# scenodico/251/show qui la contenait, donc c'est elle qu'il fallait que
# je mette en seule page à tester
# Régler aussi NOMBRE_MAX_ROUTES_TESTED ci-dessus pour limiter le test, mais
# penser à laisser un nombre assez grand pour comprendre la route à tester à
# l'intérieur de la page s'il y en a beaucoup avant.
#
# Option de ligne de commande : -r=…/-from-route=…
# FROM_ROUTE = 'site/updates'

# Si TRUE, le programme utilise les données consignées à la fin
# de la dernière analyse dans le fichier Marshal au lieu de
# recommencer complètement l'analyse.
#
# Option de ligne de commande : -D/--dumped-data
USE_DUMPED_DATA = false
