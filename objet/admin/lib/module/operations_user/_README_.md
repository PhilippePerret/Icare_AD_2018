Contrairement au traitement des modules habituel, chaque fichier de ce dossier est appelé individuellement selon l'opération à exécuter.

Cf. le fichier `./objet/admin/lib/module/users/users.rb`

Pour créer un nouvel outil :

* Créer son fichier ruby dans son dossier. L'affixe du fichier doit être l'identifiant de la méthode (par exemple `pause_module`)
* Créer dans ce fichier ruby une MÉTHODE DE CLASSE de `Admin::Users` qui porte le nom `[self.]exec_<identifiant méthode>`
* Dans le fichier `./objet/admin/lib/module/users/users.rb` ajouter au tableau des outils cet outil. Si l'outil a besoin d'un champ court, moyen ou long, il faut respectivement définir le texte de `:short_value`, `:medium_value` ou `:long_value`, qu'on peut appeler dans la méthode `exec_...` par ces mêmes noms (`short_value`, `medium_value`, `long_value`)

## Propriétés connues

### `icarien`

Instance `User` de l'icarien choisi dans le menu des icariens.

### `icarien_id`

Identifiant de l'icarien choisi dans le menu des icariens.

### `short_value`

La valeur donnée dans le champ court.

### `medium_value`

La valeur médium donnée dans le champ moyen.

### `long_value`

La valeur longue (texte) donnée dans le champ textarea.


## Affiche du log du travail

Pour construire le message final, on incrémente `@suivi` :

~~~ruby
      @suivi << 'mon message'
~~~

## Ajout d'erreurs

On peut utiliser la méthode `add_error` pour afficher une erreur dans le suivi. Ce texte s'écrira en rouge dans le suivi en retour.
