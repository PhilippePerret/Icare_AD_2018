# Snippets

* [Présentation](#presentation_de_snippets)
* [Exemple type d'utilisation](#exempletype)
* [Utilisation](#utilisation_des_snippets)
* [Définir des snippets propres](#definir_des_snippets_propres)
* [Scope des snippets](#fonction_par_scope)
  * [Définir le scope courant](#definir_le_scope_courant)
  * [Exécuter une fonction au déclenchement du snippet](#fonctiontoplay)
* [Exécuter une méthode au Retour Chariot](#executer_une_methode_au_return_seul)
* [Exécuter une méthode au CMD + Retour chariot](#executer_une_methode_on_return)
* [Méthode à appeler si touche modificatrice](#methode_a_appeler_quand_modifier)
* [Afficher un message d'aide pour le snippet](#afficher_message_help)

<a name='presentation_de_snippets'></a>

## Présentation

`Snippets` est une librairie qui permet de gérer les snippets dans les champs d'édition.

> Rappel : Un “snippet” consiste à taper le début d'un mot (ou tout autre signe) puis à faire TABULATION pour obtenir le reste. Par exemple, pour écrire un paragraphe en HTML (<p>...</p>) on tape “p” puis tabulation.


<a name='exempletype'></a>

## Exemple type d'utilisation

Voici un exemple type d'utilisation, pour que tous les textarea d'une page d'édition répondent aux snippets HTML et ERB.

La page ERB ou ruby doit appeler le module Javascript :

~~~erb

page.add_javascript(PATH_MODULE_JS_SNIPPETS)

~~~

Et dans le fichier javascript on doit trouver :

~~~javascript

$(document).ready(function(){

  // Le code pour rendre les textareas sensibles aux
  // Snippets
  Snippets.set_scopes_to([
    'text.erb', 'text.html'
  ]);
  $('textarea').bind('focus',function(){Snippets.watch($(this))})
  $('textarea').bind('blur',function(){Snippets.unwatch($(this))})


})


~~~

<a name='utilisation_des_snippets'></a>

## Utilisation

> Note : Pour une utilisation dans les sites RESTFULL, il faut importer cette librairie à l'aide du code :

    page.add_javascript(PATH_MODULE_JS_SNIPPETS)

Voici une présentation succinte de l'utilisation des snippets. Cette définition peut se faire par exemple quand on focusse sur une champ d'édition.

    // Définir les snippets, en définissant les scopes
    // Pour un scope connu (comme text.html) :
    Snippets.set_scopes_to(<scope | liste des scopes>)
    // Par exemple : Snippets.set_scopes_to(['text.html'])

    // Pour un scope personnalisé, inexistant
    Snippets.set_scopes_to(
      [
        <!-- Faire appel à un scope commun -->
        "<nom d'un scope>",
        <!--  définir d'autres snippets propres -->
        {<définition des snippets>}
      ]
    )

    // Surveille le champ de Jid +jid+ en exécutant les snippets
    // si des tabulations sont tapées
    Snippets.watch(<jid>)

Il faut penser ensuite, au blur du champ, à “unwatcher” le champ :

    on_blur:function(){

      Snippets.unwatch(<jid>)

    }

Par exemple, dans un fichier `ready.js` :

    $(document).ready(function(){

      // Snippets généraux
      Snippets.set_scopes_to() ;
      // Snippets spéciaux
      Snippets.set_scopes_to([
        "text.html", "text.erb",
        {
          'PAGE':{replace:"PAGE[$0]"},
          'FILM':{replace:"FILM[$0, $1]"}
        }
        ])

      var letextarea = $('textarea#mon_champ_de_texte');

      letextarea.bind('focus',function(){Snippets.watch($(this))})
      letextarea.bind('blur', function(){Snippets.unwatch($(this))})

      })

<a name='definir_des_snippets_propres'></a>

## Définir des snippets propres

Une définition de snippets est un Hash (Object) qui contient en clé le texte qui sera écrit (réduit) et en valeur un `Object` qui définira le texte de substitution (`replace`) et les paramètres de sélection/position finale (`select`).

Si `select` n'est pas défini, on considère qu'il faut placer le curseur à la fin du texte inséré. Sinon, on peut définir précisément où placer le curseur et quoi sélectionner à la fin.

Imaginons par exemple que nous voulions un snippet qui permette d'entrer une balise `span` en définissant sa classe CSS puis son id.

Le texte qui permettra de déclencher ce snippet (le “trigger”) est “span”, donc ce sera la clé :

    mes_snippets = {
      'span': {}
    }

Le texte de remplacement sera `<span id="ID" class="CLASSE">TEXTE</span>`. Donc :

    mes_snippets = {
      'span': {replace: '<span id="$1" class="$2">$0</span>'}
    }

<a name='fonctiontoplay'></a>

## Exécuter une fonction au déclenchement du snippet

Pour déclencher une fonction quand on joue un snippet (après la tabulation), il faut définir la propriété `func` et lui donner la valeur de la fonction (sans les parenthèse).

~~~js
  window.ma_fonction_a_jouer = function(){
    alert('Je joue la fonction.')
  }

  mes_snippets = {
    'span': {replace:'unespan', func:ma_fonction_a_jouer}
  }

~~~

<a name='fonction_par_scope'></a>

## Scope des snippets

Les snippets fonctionnent par “scope”, par exemple pour les codes HTML c'est le scope `text.html`.

<a name='definir_le_scope_courant'></a>

### Définir le scope courant

    Snippets.set_scopes_to( <array> )

Où `<array>` est une liste qui contient :

* Soit un scope string comme "text.html" ou "text.erb" ;
* Soit la définition d'un scope, c'est-à-dire un Hash définissant en clé le code du snippet et en valeur un Object définissant le texte de remplacement (`replace`) et les options de sélection finale (`options`).

Par exemple :

    Snippets.set_scopes_to(
      "text.html",
      {
        'pro': {replace:"Un snippet propre", options {length: 0, at: -5}},
        'aut': {replace:"Je suis un autre", options{end: true} }
      }
      )


<a name='executer_une_methode_au_return_seul'></a>

## Exécuter une méthode au Retour Chariot

On peut exécuter une méthode au retour chariot (souvent la soumission du formulaire) en définissant :

    Snippets.ON_RETURN = $.proxy(<object>, '<méthode>')

Si on ne veut pas court-circuiter le fonctionnement normal du retour de chariot dans un textarea, on peut utiliser plutôt le `CMD + RETURN` ci-dessous.

<a name='executer_une_methode_on_return'></a>

## Exécuter une méthode au CMD + Retour chariot

On peut exécuter une méthode au retour chariot (souvent la soumission du formulaire) en définissant :

    Snippets.ON_CMD_RETURN = $.proxy(<object>, '<méthode>')


<a name='methode_a_appeler_quand_modifier'></a>

## Méthode à appeler si touche modificatrice

C'est une fonction étendue de “Snippets” puisqu'elle ne concerne pas vraiment les snippets au sens propre du terme. C'est la faculté d'appeler une méthode déterminée lorsque les touches `COMMAND` (`meta`), `CONTROL` ou `ALT` sont pressées.

Pour ça, on définit (par exemple dans le on_focus de l'application qui utilise Snippets) :

    Snippets.ON_META_KEY = $.proxy(<objet>, '<methode>')
    Snippets.ON_CTRL_KEY = $.proxy(<objet>, '<methode>')
    Snippets.ON_ALT_KEY  = $.proxy(<objet>, '<methode>')

La méthode en question reçoit l'évènement keypress.

Noter que les méthodes sont appelées dans cet ordre, donc si deux touches modificatrices sont utilisées, c'est la fonction de la première touche qui l'emporte. Par exemple, si CTRL + ALT, c'est la méthode ON_CTRL_KEY qui sera appelée.

<a name='afficher_message_help'></a>

## Afficher un message d'aide pour le snippet

Deux conditions sont requises pour pouvoir afficher un message d'aide pour les snippets&nbsp;:

1. Avoir un élément DOM d'identifiant `snippets_help` (div ou autre, peu importe)
* De définir la propriété `help` dans les données du snippet. Par exemple&nbsp;:

      Les_snippets = {
        ...,
        'snip': {replace: "$1 beau ", help: "Mettre ce qui est beau dans $1"},
        ...
      }
