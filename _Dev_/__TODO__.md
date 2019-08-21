* # Empêcher un même message (comme le message d'accueil) de s'afficher plusieurs fois.

* Traduire les titres de mails en reprenant la formule dans la version nodejs du site

* mettre la configuration propre aux mails dans ./config/mails.rb et faire une méthode `Mail.require_config`.

* mailnoiduzep@chez.com / monmotdepasse
* Nicolas Dufourg   : crapette
* Emmanuelle Badina : crapette

* Penser à une re-structuration progressive du site (notamment au niveau du graphisme)
* Implémenter la possibilité de répondre aux mails directement sur le site.

## AVANT DE METTRE LE SITE EN LIGNE

* Il faut régler le shebang du fichier ./index.rb pour qu'il soit normal (noter qu'il faut absolument actualiser ce fichier, car il a été changé)

## BUGS

* Dans l'édition des étapes/travaux-types, s'assurer que les balises FILM soient bien formatées. Contrairement à BOA où elles ressemblent à FILM[Ali2001], sur l'atelier, elles doivent ressembler à FILM[256|Ali] donc FILM[<id>|<titre>]. S'assurer qu'on peut les avoir sous cette forme avec le code.

## PROGRAMMÉ


## À FAIRE RAPIDEMENT

* Faire un backup de tous les documents QDD actuels et zipper
* Pouvoir synchroniser les étapes de travail locales avec les distantes (en faisant très attention — mais normalement, c'est la synchro de bases de données qui devrait être utilisé)

## TESTS À FAIRE

* Tester l'historique
* Tester le Frigo
  - définition partage
  - destruction
* Tester la section "Documents" d'un icarien
* Tester le réglage profil du contact avec le monde (préférence)
  - son réglage/définition
  - son effet sur l'affichage de la liste des icariens
* Envoi de mail — Contact (à l'administration ou à un icarien en voyant toutes les options possibles)
* Dépôt de message sur le frigo de l'icarien (checker suivant les préférences contact_world et contact_icarien)
* Tester la création et la modification d'un travail-type

## DIVERS

* CRON Plutôt que de tester l'heure, enregistrer la date de dernière opération et la tester toutes les heures. Cela permettra de ne pas attendre le lendemain pour reprendre une opération qui aura échoué

* Mieux indiquer la différence entre module suivi de projet et coaching, en se servant du texte écrit à Guilhem : « Le premier se fait sur un temps déterminé (en fait, plus précisément, un certain nombre d'étapes de travail). Dans ce module, on peut très bien arriver par exemple avec un scénario déjà presque abouti. Pour le moment, il a été utilisé pour ça : préparer son entrée au CEEA, préparer son entrée en Master II de scénario, finaliser un roman, rédiger une note d'intention ou encore obtenir un script-doctoring sur plusieurs scénarios à leur version 2 ou 3. Le module "suivi de projet", a contrario, n'a pas de durée déterminée. Certains l'ont suivi pendant 4 ans ! J'y accompagne un projet des tout débuts — l'idée initiale — jusqu'au scénario ou au roman, en passant par toutes les étapes de développement. »


* Nettoyage du site par le cron

* Test du updated_at pour les étapes de travail pour récupérer corrections de Marion sur les étapes de travail.

* Lorsqu'un icarien modifie un partage de ses documents, m'avertir par mail

* Faire un "jeu de couleurs" pour les notifications, pour être capable de les reconnaitre à leur couleur.

* Permettre à un icarien de charger son avatar (ou plutôt sa photo)

* Messages de bureau (frigo)

* Pour les citations, plutôt que de les charger chaque fois, pour accélérer, charger 20 citations pour la journée et les faire "tourner" à chaque chargement de l'accueil.

* L'option 17 (18e bit) doit servir à ne recevoir aucun mail de l'atelier, jamais (même les mails par la mailing list)
  - C'est déjà réglé pour la mailing-list, mais il faut le faire pour le reste (cron actualités, autres ?)


* Pour le bouton "Documents" de l'icarien, il faudra que ça mène vraiment à une liste bureau/documents, pas au quai des docs
  - possibilité de recharger les derniers commentaires (ils sont détruits un mois après leur émission, ou quand le document QDD est déposé)
  -  indication que les documents ne présentation ne sont pas déposés sur le quai des docs
* Un user se crée "dans le vide" lorsqu'il y a une inscription, voir pourquoi.
* La SYNCHRONISATION ne fonctionne pas (offline -> online)

* Pour le moment, je ne prends que le travail du travail-type (les titres et les objectifs sont déjà rassemblés). Il faut faire un traitement pour obtenir la méthode. En fait, elle peut être "ramassée" en construisant le travail puisqu'elle sera affichée après.
* Faire un watcher admin pour le paiement, qui n'est affiché que lorsque l'icarien doit payer.
* Dans le bureau admin, regrouper les watchers par user (il suffit de les relever dans la base en les ordonnant par user_id).
* Ajouter le QDD aux outils de l'icarien
* QDD Poursuivre le set_cote.rb
* QDD Construire le processus 'quai_des_docs/cote_et_commentaire'. La notification de l'user doit conduire à une page où il peut donner une note et laisser un commentaire sur le document.

  - Attribution des cotes pour les documents (changement)

* Finir le notify pour annuler une commande de module (côté user) (pour le moment, il n'y a que le bouton)

* Le lien "Historique" doit simplement présenter la partie si l'icarien est tout jeune à l'atelier

* TODO Voir la procédure à adopter pour le fichier ./\_objet/bureau/lib/module/section_current_work/helper_abs.rb qui doit permettre à un icarien actif.

* Dans le cronjob, vérifier les watchers de paiements. Si certains sont trop en retard => envoyer des mails (user et admin) et renseigner les data du watcher pour indiquer que les mails sont envoyés. Indiquer à l'administrateur qu'il faut détruire n icarien trop en dépassement (faire un watcher icarien/destroy)

* Faire la page Facebook de l'atelier

* Cron de nettoyage pour supprimer les documents téléchargés (dossier ./tmp/download/user-xxx/). On peut vérifier que les documents ont bien été téléchargés avec la propriété options des documents (3e et 11e bit)


## CRON-JOB

* Vérifier les icmodules non démarrés (options[0]==0) depuis trop longtemps (created_at < Time.now.to_i - 1.month). Envoyer d'abord une alerte, puis une mois après le détruire.

* Définition automatique du partage des documents
  Penser à faire une annonce actualité même pour ce partage automatique, mais en modifiant le nom (au lieu de "Untel met en partage ses documents…", dire "Les documents de Untel sont mis en partage")



## À FAIRE APRÈS L'OUVERTURE

* Procédure pour déposer une question minifaq
* Mettre au point un petit déctecteur de — pas de fumée — d'incompatibilité au niveau des données de modules (notamment les abs_module_id) en fonction des étapes et des documents, et proposer des corrections à adopter ou non.

* TODO Installer le QUAI DES DOCS
  - affichage des documents par trimestre
  - recherche de documents

* TODO Installer le cron-job
  - suppression des dossiers tmp/download assez vieux (1 mois)

* TODO Installer la partie historique du bureau

* Une section du bureau administrateur qui présente l'état des icariens (un aperçu général).

## FONCTIONNALITÉS OPTIONNELLES

* Faire un javascript qui permette de supprimer la notification pour les
  download (mais seulement pour l'administrateur).
