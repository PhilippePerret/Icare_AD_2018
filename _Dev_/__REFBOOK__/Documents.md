

* [Créer un watcher pour le document](#createwatcherpourdocument)
<a name='createwatcherpourdocument'></a>

## Créer un watcher pour le document

Avec une instance `IcModule::IcEtape::IcDocument`, il suffit d'utiliser la méthode `create_watcher` avec en argument soit le processus ({String}) soit un `Hash` définissant les données minimum.

Avec un String (l'utilisateur courant doit être le possesseur du document).

    # icdocument est une instance IcModule::IcEtape::IcDocument
    icdocument.create_watcher('download')
    ou
    icdocument.add_watcher('download')

Avec un `Hash` de données on peut définir l'user-id (c'est la principal utilisation, hormis pour enregistrer d'autres data)

    icdocument.add_watcher(
      processus: 'download',
      user_id:    owner.id,
      data:       "C'est une donnée"
      )
