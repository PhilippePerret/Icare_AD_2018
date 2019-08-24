# Manuel pour les tests

* [Méthodes fréquentes](#methodes_frequentes)
  * [Pour vérifier l'existence d'un watcher](#check_watcher_exist)
  * [Pour vérifier l'existence d'une actualité](#check_update_exist})


## Méthodes fréquentes {#methodes_frequentes}

### Pour vérifier l'existence d'un watcher {#check_watcher_exist}

```ruby

dw = {... data du watcher attendu ...}
dw = watcher_should_exist(dw)
# dw contient toutes les données du watcher ou nil s'il n'existe pas

```

### Pour vérifier l'existence d'une actualité {#check_update_exist}

```ruby

du = {... data de l’actualité attendue ...}
du = actualite_should_exist(du)
# du contient toutes les données de l'actualité (ou nil)
