# Manuel pour les tests

* [Base de données](#base_de_donnees)
  * [Nombre de données dans une table](#nombre_rows_in_table)
  * [Obtenir une seule données particulière](#get_a_db_row_with_data)
  * [Récupérer plusieurs données](#get_rows_in_db)
  * [Exécuter une requête quelconque](#exec_any_request)
* [Méthodes fréquentes](#methodes_frequentes)
  * [Pour vérifier l'existence d'un watcher](#check_watcher_exist)
  * [Pour vérifier l'existence d'une actualité](#check_update_exist})
  * [Pour vérifier l'existence d'une ticket](#check_ticket_exist})
* [Mails](#les_mails)
  * [Vérifier l'existence d'un mail](#check_mail_exist)
  * [Ré-initialiser le dossier des mails](#init_mails)
  * [Récupérer tous les mails envoyés](#get_all_mails)


## Base de données {#base_de_donnees}

Plusieurs méthodes pratiques permettent de récupérer et de définir des données dans les tables à l'aide de la classe `DB`.

Noter que toutes ces méthodes utilisent le gem `MySql2`.

### Nombre de données dans une table {#nombre_rows_in_table}

`DB.count(<nom table>)` retourne le nombre de rangées dans la table `<nom table>`.

Par exemple : `DB.count('icare_users.users')` retourne le nombre d'utilisateurs.

### Obtenir une données particulière](#get_a_db_row_with_data

`DB.getOne(table, hdata)` retourne les données de la table `table` qui remplissent les conditions définies dans le hash `hdata`. La méthode ne renvoie que le premier élément trouvé.

Par exemple : `DB.getOne('icare_users.users',{state:8, mail:'monmail@chez.moi'})` retourne les données de l'utilisateur (`user`) qui a pour `state` 8 et pour mail `monmail@chez.moi`.

On peut également, à la place de `hdata`, envoyer un identifiant.

`DB.getOne('icare_modules.icmodule', 123)` retourne les données du module d'apprentissage d'identifiant 123.

# Récupérer plusieurs données {#get_rows_in_db}

La méthode `DB.get(table, hdata)` retourne la liste `Array` des données de la table `table` qui répondent aux données `hdata` où `hdata` est un `Hash` avec en clé le nom de la propriété et en valeur la valeur attendue.

On trouve aussi les propriétés spéciales `:after` et `:before` qui permettent de faire un test sur la propriété `created_at`.

Par exemple, `DB.get('icare_users.users', {after: 23789567})` retourne sous forme de liste les données de tous les utilisateurs qui ont été créés après le temps `23789567`.


### Exécuter une requête quelconque {#exec_any_request}

La méthode `DB.execute(request[, values])` permet d'exécuter la requête `request` sur la base de données avec les valeurs optionnelles `values`.

Noter que si `SIMULATION` est true (défini dans `spec_helper.rb`), c'est une simple simulation qui sera faite et si `ON_OR_OFF` est à `:online` (`:offline` par défaut), la requête sera effectuée sur la base distante.

Note : pour forcer une requête même lorsque `SIMULATION` est true, utiliser la méthode `DB.force_execute` avec les mêmes arguments.

---------------------------------------------------------------------


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

### Pour vérifier l'existence d'une ticket {#check_ticket_exist}

```ruby

dticket = ticket_should_exists({data})
# => {id:..., user_id:... code:..., created_at:..., updated_at:...}

```

`dticket` est une table contenant toutes les données du ticket

## Mails {#les_mails}

### Vérifier l'existence d'un mail {#check_mail_exist}

```ruby

dmail = {... data du mail ...}
instance_mail = mail_should_have_be_sent(dmail)

```

Note : contrairement aux autres méthodes, celle-ci retourne une *instance* de `TMail`, qui permet de faire d'autres tests encore.

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

La méthode `get_all_mails` permet de récupérer tous les mails envoyés depuis que la commande `reset_mails` a été invoquées. C'est une liste d'instances `TMail`.
