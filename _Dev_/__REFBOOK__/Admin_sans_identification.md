# Admin sans identification

* [Principe général](#principedefonctionnement)
* [Utilisation concrète](#utilisationconcrete)
* [Envoi de données](#envoidedonnees)
* [Visite en tant qu'un icarien](#visiteentantquicarien)

C'est une procédure qui permet d'exécuter des opérations comme admnistrateur sans pour autant être identifié.

> Cette procédure a été mise en place pour pouvoir utiliser CURL dans les tests pour exécuter des opérations en test d'intégration.

<a name='principedefonctionnement'></a>

## Principe général

Avant un appel :

* Création d'un nombre aléatoire (-> nombre_alea)
* Création d'un fichier dans le dossier `./tmp/__adm/` portant le nom `<nombre_alea>` et contenant l'id de session courante.

Appel :

* On appelle l'url quelconque en ajoutant en paramètre `__adm=<nombre_alea>`

Réception appel :

* En recevant l'appel, l'application détecte le paramètre `__adm`
* Elle cherche le fichier `./tmp/__adm/<nombre_alea>`
* Elle lit son contenu et le compare à la valeur de session
* Si matche, elle autolog en administrateur
* Elle détruit le fichier nombre_alea (usage unique)

<a name='utilisationconcrete'></a>

## Utilisation concrète

Pour pouvoir utiliser ce fonctionnement, on utilise simplement la méthode :

    app.curl_as_admin <url>[, options]

Par exemple, pour jouer un watcher en online :

    app.curl_as_admin 'watcher/12/run', online: true

<a name='envoidedonnees'></a>

## Envoi de données

Utiliser le second paramètres, propriété :data :

~~~

  app.curl_as_admin 'watcher/12/run', online: false, data: {une: "donnée"}

~~~

<a name='visiteentantquicarien'></a>

## Visite en tant qu'un icarien

La même procédure doit être utilisable pour visiter le site en tant qu'un icarien. Cf. dans le bureau d'administrateur, l'outil 'Visiter en tant que…'.
