Dossier contenant les textes d'aide

* [Comment choisir entre fichier MD et ERB ?](#commentchoisirentremdeterb)
* [Comment créer un lien d'aide vers ces fichiers](#creerunlinedaideverscesfichiers)


<a name='commentchoisirentremdeterb'></a>

## Comment choisir entre fichier MD et ERB ?

Les fichiers markdown sont plus simples à rédiger mais ne permettent pas la souplesse des fichiers ERB au niveau des variables ou des codes ruby utiles.

Il faut employer `Markdown` lorsqu'on ne doit pas féminiser le texte.

<a name='creerunlinedaideverscesfichiers'></a>

## Comment créer un lien d'aide vers ces fichiers

Lien qui sera un point d'interrogation lié au fichier d'aide :

    lien.aide(<numéro fichier>)

    Où <numéro fichier> est le numéro au début du nom du fichier,
    juste avant le tiret.

Lien avec un titre spécifique :

    lien.aide(<numéro>, <titre>)

Par exemple, pour rejoindre la page d'aide sur les raisons de l'abonnement, qui s'appelle `3-why_subscribe.erb`, utiliser :

    <%= lien.aide(3, "Pourquoi s'abonner") %>

Lien avec plus de définition :

    lien.aide(<numéro>, <{hash de données}>)

Par exemple :

    lien.aide(3, {titre: "Vers les raison", class: 'class_css', target: :new})

On peut utiliser aussi la route :

    aide/<numéro>/show

Donc :

    'Un lien vers l’aide'.in_a(href: 'aide/3/show')
