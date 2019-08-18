# encoding: UTF-8
=begin

Pour ajouter des options, les ajouter aussi au fichier :
    ./config/site.rb

On peut tester une valeur simplement par :

    site.<propriété>

=end
app.benchmark('-> site/config.rb')

defined?(HOME) || HOME = "/Users/philippeperret"

# Désignation officielle du site, par exemple pour les
# factures ou autre mail officiel
site.official_designation = "Atelier ICARE" # "Writer's Toolbox"
site.name                 = "Atelier Icare"
# Pour donner un nom différent dans la balise <title>
# Si non défini, c'est la valeur de site.name qui sera prise
# et PASSÉE EN CAPITALES
site.title = "ICARE"

# Pour composer la balise TITLE de la page
# Le title_prefix servira pour toutes les autres pages de l'accueil
# Dans les vues, utiliser `page.title = <valeur>` pour définir ce
# qui doit suivre ce préfixe
site.title_prefix     = "ICARE"
site.title_separator  = " | "
site.logo_title = "Atelier Icare"

# Le mail pour le paramètre `:to` de l'envoi de mail notamment, ou
# pour écrire les infos à propos du site
site.mail                 = "phil@atelier-icare.net"
site.mail_before_subject  = "ICARE — "
site.mail_signature       = "<p>#{site.name}</p>"
# Liste des mails à éviter, qui correspondent à des users qui
# ont changé d'adresse sans le signaler.
site.mails_out = [
  'domideso@hotmail.fr',
  'rocha_dilma@hotmail.com'
]

# Host local
site.local_host   = 'localhost/AlwaysData/Icare_AD_2018'
site.distant_host = 'www.atelier-icare.net'
site.domain_url   = "http://#{site.distant_host}"

# Description qui servira pour la balise META
#
# On peut affiner cette description par page en ajoutant la définition :
# page.description = "<description précise de la page>"
site.description = <<-TEXT
Atelier d'écriture (film, roman, BD, jeux) animé par le scénariste, romancier et pédagogue Philippe Perret.
TEXT

# Les mots-clés du site
# Cette liste servira pour la recherche de positionnement du site dans les
# recherches Google (chercher 'Ranking')
# Note : Il faut absolument que ce soit une liste Array.
site.keywords = [
  'écrire',
  'scénario',
  'film',
  'roman',
  'écrire un scénario',
  'écrire un roman',
  'analyse de film',
  'dramaturgie',
  'règles d\'écriture'
]
# Pour essayer sur un seul mot-clé :
# site.keywords = ['écrire un scénario']

# Si le site a un absonnement
# site.tarif = 6.90

# ---------------------------------------------------------------------
#   DONNÉES DE L'UTILISATEUR

# Redirection possible
# cf. le fichier ./objet/user/lib/required/user/instance/redirections.rb
# pour la définition des routes.
site.redirections_after_login = {
  0 => {hname: 'Accueil du site',         route: :home},
  1 => {hname: 'Bureau de travail',       route: :bureau},
  2 => {hname: 'Profil',                  route: :profil},
  3 => {hname: 'Dernière page consultée', route: :last_page},

  # - ADMINISTRATEUR -
  7 => {hname: 'Aperçu Icariens', route: 'admin/overview', admin: true},
  8 => {hname: 'Console', route: 'admin/console', admin: true},
  9 => {hname: 'Tableau de bord', route: 'admin/dashboard', admin: true}
}

# Mettre à true si le formulaire d'inscription doit demander
# l'année de naissance de l'user
site.signup_with_year           = true
site.signup_year_required       = true
site.signup_with_coordonnates   = true
site.signup_phone_required      = false
site.signup_address_required    = false
site.signup_patronyme_required  = false

# Pour les captcha (pour faire au moins 6)
# Mettre captcha_value à nil pour ne pas utiliser de captcha
# là où il en faudrait.
x = rand(18) + 2
y = rand(10) + 4
site.captcha_value    = (x + y).to_s
x = x.to_s.in_span(id:'xcap') # xcap sert pour les tests
y = y.to_s.in_span(id:'ycap')
site.captcha_question = "Combien font #{x} + #{y} ?&nbsp;&nbsp;&nbsp;&nbsp;"
# ---------------------------------------------------------------------
#   BASES DE DONNÉES
site.prefix_databases = 'icare'

# Compte Facebook
# ---------------
# Un lien sera ajouté automatiquement à la signature
# des mails si le compte est défini.
# site.facebook = 'laboiteaoutilsdelauteur'

# Compte Twitter
# --------------
# Un lien sera ajouté automatiquement à la signature
# des mails si le compte est défini.
# site.twitter = 'b_outils_auteur'

# # Si on est en anglais :
# site.separateur_decimal = "."
# site.devise = "$"

# Définition propre des bits options de l'utilisateur
# Cf. RefBook > User > Options.md
site.user_options = {
  state: [16, '@state']
}

# Soit :textmate, soit :atom, l'éditeur à utiliser
# quand on a recours à `lien.edit_file <path>`
site.default_editor = :atom
# Application (nom) qui doit ouvrir les documents Markdown
# à l'édition.
# Note : Il faut que cette application existe, dans le cas
# contraire, c'est l'application par défaut de l'ordinateur
# qui serait utilisée.
site.markdown_application = "TextMate" # "Mou"

site.serveur_ssh = "icare@ssh-icare.alwaysdata.net"

# ---------------------------------------------------------------------
# ADMINISTRATION

# Si cette option est true, une pastille en haut à droite de la
# page indiquera aux administrateurs les tâches qu'ils sont à
# accomplir.
# Cette pastille est insérée dans la page :
#   ./_view/gabarit/header.erb
site.display_taches_for_administrator = true

# Si cette option est true, une pastille en haut à droite de
# la page indiquera à l'user les tâches qu'il a à accomplir
# si l'application le nécessite et le gère.
site.display_taches_for_user = true

# Si cette option est true, le widget des tâches est affiché
# pour l'administrateur
site.display_widget_taches = false

# Mettre à true pour affiche un champ où est inscrit un nom qui permet
# de nommer un fichier concernant la page courante. Permet de faire des
# relecture-correction facilement en créant un document PDF par exemple
site.afficher_helper_filename_lecteur = false

# Détermine les alertes administration lors du login d'un
# utilisateur. Les valeurs peuvent être :
# :never / :jamais        Aucune alerte n'est donnée.
# :now / :tout_de_suite   Alerte immédiate : dès que l'user se
#                         connecte au site, l'administion est avertie
# :one_an_hour / :une_par_heure
# :twice_a_day / :deux_par_jour
#     Deux résumés par jour, à midi et à minuit
# :one_a_day / :une_par_jour
#     Résumé quotidien des connexions de la journée
# :one_a_week / :une_par_semaine
#     Résumé hebdomadaire des connexions de la semaine
# :one_a_month / :une_par_mois
#     Résumé mensuel des connexions du mois
site.alert_apres_login = :twice_a_day

# ---------------------------------------------------------------------
# TESTS
# Chemin d'accès au binaire `rpsec` pour lancer les tests
# façon console. Pour obtenir cette valeur, taper `which rspec` dans le
# Terminal.
site.rspec_command = File.join(HOME, '.rbenv/shims/rspec')

app.benchmark('<- site/config.rb')
