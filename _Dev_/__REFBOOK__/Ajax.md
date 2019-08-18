# Ajax

* [Envoi d'une requête](#envoidunerequetee)
* [Propriétés définissables](#proprietesdefinissables)
* [Renvoi de données aux programmes](#renvoiededonnees)
* [Messages de retour](#messagederetour)
* [Erreurs de retour](#erreurderetour)
* [Auto-sélection du contenu des champs de texte quand focus](#autoselectquandfocus)


<a name='envoidunerequetee'></a>

## Envoi d'une requête

OBSOLÈTE : La donnée indispensable pour envoyer une requête Ajax est la donnée `url` qui définit la route à employer, exactement comme on le ferait depuis une page avec un lien normal.

C'est maintenant l'argument `route` qu'il faut définir.

Par exemple, si on veut invoquer le script :

    ./\_objet/mon_objet/mon_module

… on définit `route` à :

    mon_objet/mon_module

Donc :

    Ajax.send({
      route: "mon_objet/mon_module",
      ma_donnee_1: "<les données envoyées>",
      ma_donnee_2: "<autre donnée>",
      onreturn: $.proxy(la méthode pour poursuivre)
      })

OBSOLÈTE : Noter que pour le moment l'url ne fonctionne pas avec les sous-objets. Donc on ne peut pas faire :

    url: "livre/folders?in=cnarration"

Maintenant, on peut très bien fonctionner avec les sous-objets :

    route: "livre/folders?in=cnarration"

<a name='proprietesdefinissables'></a>

## Propriétés à définir

Il faut définir la méthode javascript qui traitera le retour ajax.

    onreturn:       Méthode de retour

    message_on_operation:   Message d'opération


<a name='renvoiededonnees'></a>

## Renvoi de données aux programmes

    Ajax << {<hash de données>}


<a name='messagederetour'></a>

## Messages de retour

On utilise la méthode `flash` de façon tout à fait normale pour ajouter des messages notice.

Noter que ces messages de retour s'affichent automatiquement, sans autre forme de programmation.

<a name='erreurderetour'></a>

## Erreur de retour

Pour ajouter des messages d'erreur, on utilise tout naturellement la méthode `error`

    error 'Une erreur qui sera retournée et affichée.'

Noter qu'elles s'affichent automatiquement sans autre intervention.

<a name='autoselectquandfocus'></a>

## Auto-sélection du contenu des champs de texte quand focus

Pour obtenir que les champs de texte (input-text et textarea) se sélectionnent quand on focus dedans, on peut utiliser la méthode :

  UI.auto_selection_text_fields()

Noter qu'elle est déjà appelée par défaut au chargement de la page, donc qu'elle n'est à utiliser que lorsqu'on recharge du texte par ajax.
