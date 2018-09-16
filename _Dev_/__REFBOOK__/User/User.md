# Utilisateur

* [Procédure de paiement](#paiement)
* [Mailing list](#mailinglist)
  * [Exclusion de mails](#exclusiondemails)


<a name='paiement'></a>

## Procédure de paiement

La procédure de paiement est un watcher un peu spécial : le formulaire de paiement appelle `ic_paiement/main` au lieu de la route traditionnelle pour runner le watcher, l'user procède au paiement et en cas de succès, le watcher est runné pour être terminé (et principalement : envoi des mails à l'user et à l'administrateur, création du watcher suivant si nécessaire et destruction du watcher).

<a name='mailinglist'></a>

## Mailing list

<a name='exclusiondemails'></a>

### Exclusion de mails

Pour exclure des mails des mailings list, on peut définir dans la configuration du site la propriété :

    site.mails_out = [....]

Tous les mails contenus dans la liste seront exclus des envois, même pour les mails d'activité ou autre.
