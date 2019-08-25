# Manuel pour les tests

* [Méthodes fréquentes](#methodes_frequentes)
  * [Pour vérifier l'existence d'un watcher](#check_watcher_exist)
  * [Pour vérifier l'existence d'une actualité](#check_update_exist})
* [Mails](#les_mails)
  * [Vérifier l'existence d'un mail](#check_mail_exist)
  * [Ré-initialiser le dossier des mails](#init_mails)
  * [Récupérer tous les mails envoyés](#get_all_mails)

## Méthodes fréquentes {#methodes_frequentes}

### Pour vérifier l'existence d'un watcher {#check_watcher_exist}

```ruby

dw = {... data du watcher attendu ...}
dw = watcher_should_exist(dw)
# dw contient toutes les données du watcher ou nil s'il n'existe pas

```

Les données du watcher peuvent contenir n'importe quelle donnée de colonne parmi `:id`, `:user_id`, `:objet`, `:objet_id`, `:processus`, `:data`, `:created_at`, `:triggered`.

Elles peuvent aussi contenir la propriété temporelle `:after` ou `:before` qui détermine le temps après ou avant lequel le watcher doit avoir été produit.

### Pour vérifier l'existence d'une actualité {#check_update_exist}

```ruby

du = {... data de l’actualité attendue ...}
du = actualite_should_exist(du)
# du contient toutes les données de l'actualité (ou nil)

```

Les données de l'actualité peuvent contenir n'importe quelle donnée de colonne parmi `:id`, `:user_id`, `:message`, `:status`, `:data`, `:created_at`, `:triggered`.

Elles peuvent aussi contenir la propriété temporelle `:after` ou `:before` qui détermine le temps après ou avant lequel le watcher doit avoir été produit.

## Mails {#les_mails}

### Vérifier l'existence d'un mail {#check_mail_exist}

```ruby

dmail = {... data du mail ...}
dmail = mail_should_be_sent(dmail)

```

La méthode produit un succès si le mail a été trouvé, un échec dans le cas contraire. Elle retourne l'intégralité des données si le mail est trouvé.

Les données de l'actualité peuvent contenir n'importe quelle donnée de colonne parmi :

```

  :from           Mail de l'expéditeur
  :to             Mail du destinataire
  :subject        Sujet tel que fourni par l'application à Mail
  :fsubject       Sujet entièrement formaté
  :full_subject   Sujet fourni avec l'entête éventuel
  :content        Texte ou liste de textes à trouver dans le message brut
  :fcontent       Texte ou liste de textes à trouver dans le message formaté
  
  :count          Le nombre de mails attendus (1 par défaut)
  :after          Time après lequel le mail a été envoyé
  :before         Time avant lequel le mail a été envoyé

```


### Ré-initialiser le dossier des mails {#init_mails}

La méthode `reset_mails` permet de réinitialiser tous les mails, de vider le dossier qui les reçoit en mode test et offline.

### Récupérer tous les mails envoyés {#get_all_mails}

La méthode `get_all_mails` permet de récupérer tous les mails envoyés depuis que la commande `reset_mails` a été invoquées. C'est une liste d'instance `TMail`.
