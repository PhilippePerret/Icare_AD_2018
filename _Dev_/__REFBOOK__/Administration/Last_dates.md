# Dernières dates

* [Enregistrer une dernière date de…](#enregistrerunedernieredate)
* [Récupérer une dernier date de…](#recupererunedernieredatede)

La table `site_hot.last_dates` permet de consigner des dates de dernières opérations, par exemple la dernière date d'envoi du mail d'actualité.

<a name='enregistrerunedernieredate'></a>

## Enregistrer une dernière date de…

    site.set_last_date <key>[, <time>]

Par défaut, le temps est le temps courant, sinon il peut être spécifié par `<time>`.

Noter que c'est un timestamp qui est enregistré ({Fixnum}), pas une date.

<a name='recupererunedernieredatede'></a>

## Récupérer une dernier date de…

    dernieredate = site.get_last_date <key>[, <default value>]
    # => nombre de secondes

    realtime = Time.at(dernieredate)

Retourne la dernière date correspondant à la clé `<key>` et retourne la valeur `<default value>` dans le cas où cette clé ne serait pas encore enregistrée.

Noter que c'est un timestamp qui est enregistré ({Fixnum}), pas une date. C'est un Fixnum, nombre de secondes, qui est retourné.
