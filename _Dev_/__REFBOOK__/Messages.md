## Messages

Les messages sont gérés (pour le moment) par le fichier `App/flash.rb`.

### Afficher un message à l'user

```

flash "Le message"

```

### Afficher un message d'erreur

```

error "Le message d'erreur"

```

### Afficher une liste de messages d'erreur

La méthode `errors_as_list(liste_erreurs[, options])` permet d'afficher une liste d'erreurs vraiment comme une liste, avec des puces, décalée un peu à droite.
