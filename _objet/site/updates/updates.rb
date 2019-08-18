# encoding: UTF-8
site.require_all_in('./_objet/site/updates')

=begin

Fonctionnement :
  - Quand on effectue certaines opérations, ça s'inscrit dans
    un historique.
  - C'est cet historique que cette section lit, nombre d'historiques
    après nombre d'historiques.

Liste des choses qui peuvent provoquer un enregistrement dans l'historique

- Une amélioration du site enregistrée par la console
  Mot clé "update"
    $> update
          message:"Le message d'actualisation"
          le:<date>
          type:<type>
          route: <route vers la page>
          annonce: 1/0/true/false/inscrits/abonnés
  Exemple
    $> update message:"Nouvelle page narration" le:-15 type: narration

    Si "annonce" est 1/true, alors il faudra annoncer cet update
    aux inscrits et aux abonnés suivant le choix.

- Une modification forcée (par exemple une nouvelle page Narration)
  - Correction importante d'une page Narration
  - Correction importante d'une analyse de film

UPDATES AUTOMATIQUES
--------------------
  Ci-dessous la liste des modifications qui doivent automatiquement
  produire une update dans la base.

  - Une page de Narration passe à un certain niveau de développement
    lisible (>= 8)
    type = narration
  - Une nouvelle analyse de film qui passe à lisible
    type = analyse
  - Une amélioration du programme UN AN
    type = unan
  - Une nouvelle vidéo
    type = video
  - Des messages sur le forum
    On en fait la liste tous les jours pour l'annoncer
    type: forum
  - Une nouvelle définition dans le scénodico
    type: scenodico
    Le problème ici est que la définition se fait ONLINE, donc
    c'est seulement lors de la synchro qu'on peut faire ça
  - Une nouvelle fiche de film
    type: filmodico
    Même remarque que pour le scénodico.

=end
site.require_module('Updates')
