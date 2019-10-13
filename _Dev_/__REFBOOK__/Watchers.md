# Les Watchers

* [Fonctionnement résumé des watchers](#resumedufonctionnement)
* [Styles des notifications](#styledesnotifications)
* [Fabrication des notifications](#fabricationdesnotifications)
  * [Titre de la notification](#titredesnotifications)
  * [Formulaire de notification](#formulairedenotification)
* [Le fichier main.rb](#fichiermainerb)
  * [Création d'un watcher pour l'user](#creationdunwatcher)
  * [Envoyer un autre mail que le mail par défaut](#envoyerunautremailquelemaildefault)
  * [Empêcher l'envoi du mail](#nepasenvoyerlemailprevu)
* [Chargement automatique d'un fichier librairie](#ficheirlibrairiechargedauto)


On peut lire avec profit la document sur la version précédente de l'atelier.

<a name='resumedufonctionnement'></a>

## Fonctionnement résumé des watchers


Ce qu'il faut comprendre et retenir :

Les dossiers processus associés aux watchers peuvent contenir ces éléments :

    user_notify.erb
    admin_notify.erb
    main.rb
    user_mail.erb
    admin_mail.erb

Ces éléments fonctionnent dans l'ordre donné :

~~~

    user_notify.erb   | produisent des notifications qui sont
    admin_notify.erb  | affichées sur les bureaux respectifs.
                      | Elles contiennent un formulaire qui peut
                      | déclencher le main.rb

    main.rb           | Il est en général déclenché par une des
                      | notification précédente.
                      | Il produit le travail voulu sur l'élémnet
                      | voulu et désigné par le watcher

    user_mail.erb     | Des mails qui sont envoyés à l'user ou à l'admin
    admin_mail.erb    | pour avertir ou informer de l'exécution du processus

~~~

### Par exemple

Un nouvel user a commandé un module d'apprentissage. L'administrateur l'autorise à le suivre (ce qui a été généré aussi par un watcher). En l'autorisant, ça crée un watcher pour l'user qui contient ces données :

~~~

    user_id:      ID de l'user qui doit démarrer le module
    objet:        'icmodule'    Car c'est un module qui doit être démarré
    objet_id:     ID du module absolu, dans la table des modules absolus
    processus:    'start'     C'est ce processus qui doit être appelé.

~~~

Et donc on trouve le processus défini dans le dossier :

~~~

    ./_objet/icmodule/lib/_processus/start

~~~

Dans ce dossier on trouve les fichiers :

~~~

    user_notify.erb
    main.rb
    user_mail.erb
    admin_mail.erb

~~~

Fonction de chaque fichier :

~~~
user_notify.erb

    Il contient le code pour la notification pour l'user qui lui
    permettra de démarrer le module. C'est un formulaire déclenchant
    le watcher de l'user en fournissant simplement l'ID du watcher dans
    la table des watchers.

main.rb

    Ce module est appelé lorsque l'user soumet le formulaire du fichier
    user_notify.erb. Cela a pour effet de démarrer le module d'apprentis-
    sage, c'est-à-dire de créer un icmodule pour l'user.

    Noter que l'appel à ce module, s'il fonctionne correctement, détruit
    le watcher concerné.

user_mail.erb

    Mail envoyé à la fin du processus pour confirmer à l'user le
    démarrage de son module.

    Noter que le processus peut modifier l'adresse du mail (@user_mail) pour
    qu'un autre message soit utilisé. C'est par exemple le cas pour la
    validation ou le refus de l'insscription. En cas de refus, c'est le
    mail `user_mail_refus.erb` qui doit être transmis
    (cf. ic_module/lib/_processus/attribut_module/main.rb)

admin_mail.erb

    Mail envoyé à la fin du processus pour informer l'administrateur
    que l'user a démarré son module d'apprentissage.
~~~

<a name='styledesnotifications'></a>

## Styles des notifications

Par défaut, les `p` et les `div` de premier niveau dans la notification seront considérés comme des `notice` et auront donc le style de simples notifications.

Les *formulaires* de “premier niveau” (donc en haut de la notification), ont par défaut le style `action` et sont considérés comme des actions à faire. On peut leur ajouter cette class `action` pour la clarté mais elle est plutôt réservée à des formulaires qui seraient à l'intérieur d'autres éléments.

Ces styles sont modifiés si le LI qui les contient est de class `warning`, suite à un retard. Rappel : on est en "retard" lorsque le triggered du watcher est dépassé de plus d'une semaine (7 jours).

---------------------------------------------------------------------

<a name='fabricationdesnotifications'></a>

## Fabrication des notifications

Les notifications des watchers seront affichés sur le bureau de l'icarien ou de l'administrateur. Ce sont respectivement les fichiers `user_notify.erb` et `admin_notify.erb`.

Ces notifications s'affichent à partir du moment où le watcher existe. Donc, pour les comprendre, on peut ajouter "POUR" devant le nom du watcher. Par exemple, si le watcher est "admin_download", son fichier `admin_notify.erb` servira à l'administrateur "pour downloader le fichier".

<a name='titredesnotifications'></a>

### Titre de la notification

Le titre de la notification se met dans un `legend` :

~~~html

  <legend>Le titre de la notification</legend>

  OU

  <%= 'Titre de la notification'.in_legend %>

~~~

Note : il peut se mettre dans le formulaire, au-dessus, par exemple :

~~~erb

  <%=
    form do
      'Mon titre de notification'.in_legend +
      <un autre champs>
    end
  %>
~~~

<a name='formulairedenotification'></a>

### Formulaire de notification

Les formulaires de notification peuvent utiliser maintenant une toute nouvelle tournure, qui ressemble à de la DSL mais qui n'en est pas. Le code ressemble à :

```rb

# Un commentaire sur le code
FORM id:'mon_formulaire'

  DIV id:'container'
    DIV "Text du div contenu dans le div#container"
  LEGEND  "Une légende inconnue"
  LABEL   "Juste un label"
  DIV display:'none' "Un div contenant ce texte, mais caché."

  DIV id:mon_id "Un div contenant un code à évaluer renvoyant l'id"
    # Noter que pour que ça fonctionne, 'mon_id' doit être une
    # méthode-propriété et que son propriétaire doit être envoyé
    # en premier argument de la méthode `build` qui construit le
    # formulaire.

  # Un menu peut être spécifié de cette manière
  SELECT id:'id-menu' values:'methode_evaluee_retournant_valeurs'
  DIV "<%= select_construit_par_le_programme %>"
  # Un Checkbox
  CHECKBOX name:'mon-cb' value:'oui' "Il faut cliquer cette case !"
  # Des divs de différents format
  MAIN_DIV "Un div mis en exergue" class:'autre'
  SMALL_DIV "Un div contenant un texte plus petit" id:'mon-id-de-div'
  TINY_DIV  "Un div contenant un texte minuscule"
  # La bande inférieure des boutons
  BUTTONS
    # Pour mettre des choses à gauche
    LEFT
      A href:'mon/lien/perso' "Le titre du lien"
      BUTTON "Mon bouton" onclick:'Objet.activate.call(Objet)'
    SUBMIT "Soumettre le formulaire"

```

Le nom du fichier doit être un script ruby, avec `f2c` ajouté (pour `FormToCode` qui est la classe s'occupant de la transformation). Par exemple `admin_notify.f2c.rb` produira le fichier `admin_notify.erb`.

Il suffit ensuite d'appeler une méthode — par exemple dans le fichier `required.rb` du watcher — une méthode qui va contenir :

```ruby

def construit_le_form
  site.require_module 'Form2Code'
  FormToCode.new((self.folder+'admin_notify.f2c.rb').to_s).build
end

# ...

construit_le_form

```

Principes de l'implémentation :

* c'est l'indentation qui détermine l'appartenance,
* les attributs (avec leur valeur) ne sont séparés que par des espaces simples,
* il ne faut pas d'espace entre l'attribut et sa définition
* la valeur textuelle peut être stipulée où l'on veut, au début, à la fin, ou entre les attributs.


---------------------------------------------------------------------

<a name='fichiermainerb'></a>

## Le fichier main.rb

Le fichier `main.rb` est celui qui accompli l'action proprement dite du watcher. Il “exécute le processus”. Plus exactement :

~~~

  - Il exécute la suite des opérations demandée (toute sorte d'opération)
  - Il envoie le mail défini à l'administration si ce mail existe
  - Il envoie le mail défini à l'user si ce mail existe

~~~

Noter que ce fichier charge aussi la librairie `required.rb` si elle existe.

Ce fichier est interprété par le module `running` des watchers, qui gère la méthode `run` des watchers.

Il est exécuté dans le contexte du watcher ({SiteHtml::Watcher}) donc on a accès à toutes ses méthodes.

<a name='envoyerunautremailquelemaildefault'></a>

### Envoyer un autre mail que le mail par défaut

Par défaut, c'est le fichier `user_mail.erb` ou `admin_mail.erb` qui est envoyé respectivement à l'icarien ou à l'administrateur. On peut néanmoins modifier ce mail, dans `main.rb`, simplement en redéfinissant `@user_mail` ou `@admin_mail`, en mettant le chemin d'accès au nouveau fichier.

Le plus simple est de placer ce mail alternatif dans le même dossier et de faire, dans `main.rb` :

~~~

  # Pour le mail de l'user :
  @user_mail = folder + 'user_mail_alternatif.erb'

  # Pour le mail de l'administrateur :
  @admin_mail = folder + 'admin_mail_alt.erb'

~~~

<a name='nepasenvoyerlemailprevu'></a>

## Empêcher l'envoi du mail

> Note : il peut s'agir aussi bien du mail pour l'administrateur (`admin_mail.erb`) que du mail pour l'user (`user_mail.erb`).

Insérer n'importe où dans le fichier principal `main.rb` :

~~~

  no_mail_admin

  et/ou

  no_mail_user

~~~

C'est utile, par exemple, lorsque je n'envoie pas de commentaire sur un document. Il ne faut pas envoyer le mail prévu à l'icarien, qui doit l'avertir du dépôt de ses commentaires.


<a name='creationdunwatcher'></a>

### Création d'un watcher pour l'user

Le plus simple pour créer un watcher dans le fichier `main.rb` est la tournure :

~~~ruby

    owner.add_watcher(
      ... données ...
    )

~~~

Les données peuvent se réduire à `:objet`, `:objet_id` et `:processus`.

~~~ruby

    owner.add_watcher(
      objet:      'ic_module',
      objet_id:   icmodule.id,
      processus:  'start'
    )

~~~

---------------------------------------------------------------------


<a name='ficheirlibrairiechargedauto'></a>

## Chargement automatique d'un fichier librairie

Si le dossier du processus contient un fichier `required_rb` il est chargé automatiquement autant pour produire la notification admin ou user que pour produire les mails ou exécuter le main.rb.

Cela permet de mettre des méthodes communes à tous les éléments.

Noter que dans ce fichier required il vaut mieux mettre les méthodes dans la classe SiteHtml::Watcher afin qu'il n'y ait pas de "fuite" ou d'effet de bord avec d'autres watchers. Donc :

~~~

  class SiteHtml
    class Watcher
      def ma_methode_commune_pour_un_processus
        ...
      end
    end
  end

~~~
