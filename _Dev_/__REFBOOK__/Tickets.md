# Tickets

* [Création d'un nouveau ticket](#creationdunticket)
* [Code à exécuter](#codeaexecuter)
* [Fonctionnement interne des tickets](#fonctionnementinterne)

Les “tickets” permettent d'accomplir des actions à l'aide d'un simple lien/mail. Ils ont été inaugurés pour valider l'inscription de l'utilisateur :

L'utilisateur s'inscrit. Un mail lui est alors envoyé pour qu'il valide son inscription (cette validation vérifie aussi que le mail soit le bon). Dans ce mail se trouve un lien d'activation qui fonctionne avec un ticket. Lorsqu'il active ce lien, l'user rejoit le site, exécute le ticket, ce qui valide son inscription (3e bit de ses options mis à 1).

<a name='creationdunticket'></a>

## Création d'un nouveau ticket

Pour créer un ticket, il faut :

    un ID de ticket     (alphanumérique de 32 signes max)
                        Si on met nil à la méthode create_ticket, ça
                        affecte automatiquement un id valide et unique

    un CODE à exécuter  (de préférence l'appel à une méthode qui se chargera
                         de tout)

Puis on appelle la méthode `app.create_ticket` avec cet ID et ce CODE pour le créer.

    letick = app.create_ticket(ticket_id, ticket_code)

    OU (pour obtenir un id automatiquement)

    letick = app.create_ticket(nil, ticket_code)

Ensuite, il suffit utiliser le lien à coller dans un mail par exemple :

    <%= letick.link[ "<titre du lien>"] %>

Noter qu'il est inutile de dire à `app` de quel ticket il s'agit puisqu'elle connait `@ticket` pendant la durée du processus. En revanche, si plusieurs tickets devaient être créés, il faut récupérer les valeurs tout de suite :

    app.create_ticket(tid1, tcode1)
    liento_ticket1 = app.ticket.link.freeze

    app.create_ticket(tid2, tcode2)
    liento_ticket2 = app.ticket.link.freeze

<a name='codeaexecuter'></a>

## Code à exécuter

Le code à exécuter (second argument fourni à `create_ticket`) doit être du code ruby valide. Le mieux est d'utiliser une méthode existante qui va se charger du travail. Par exemple :

    code = "User.get(#{user.id}).execute_cette_fonction"

En supposant que l'utilisateur courant ait l'id 12, le code suivant sera enregistré dans le ticket :

    "User.get(12).execute_cette_fonction"

C'est ce code qui sera exécuté lorsque le ticket sera exécuté :

    eval("User.get(12).execute_cette_fonction")

<a name='fonctionnementinterne'></a>

### Methode d'auto-login

Une méthode très pratique avec les tickets permet d'auto-logger l'user et de le rediriger vers la route voulu :

    User#autologin <args>

Avec `args` qui peut définir `:route`, la route à prendre.

Par exemple :

    ticket_code = User.new(12).autologin(route: 'user/paiement')

## Fonctionnement interne des tickets

C'est au chargement de la page qu'on teste si un ticket a été défini dans l'URL par le paramètre `tckid`. S'il existe, le préambule (`./_lib/preambule.rb`) appelle la méthode check_ticket qui appelle l'exécution de ce ticket'exécuter :

    app.execute_ticket( ticket_id )

Noter que toutes les erreurs sont gérées (inexistence du ticket, mauvaise possesseur, erreur de code).
