# Formulaire


* [Protection des formulaires](#protectiondesformulaires)
* [Utilisation d'un captcha dans le formulaire](#utilisationduncaptcha)
* [Dimensions des colonnes de libellé et de value](#dimensionsdeuxcolonnes)
* [Requérir les méthodes pratiques](#requerirmethodespratiques)
* [Méthodes de construction des champs](#methodesdechamp)
* [Options pour les champs](#optionspourleschamps)
* [Définir un préfix pour NAME et ID](#definirunprefixpourlesnameetid)
* [Mise en exergue des champs](#mettreneexerguedeschamps)
* [Définition de l'objet édité ou du hash de données](#definitiondunobjet)



## Protection des formulaires {#protectiondesformulaires}

Deux méthodes de `app` permettent de protéger les formulaires contre les rechargements de page.

La première permet d'insérer une champ caché dans le formulaire, qui contient un “checksum” qui sera vérifié à la soumission par le deuxième méthodes :

À mettre dans le formulaire à soumettre et protéger :

~~~ruby

  app.checkform_hidden_field <form_id>
  # => champ hidden à coller dans le formulaire

~~~

À appeler avant le traitement du formulaire :

~~~ruby

    app.checkform_on_submit

~~~

Cette dernière méthode raise une erreur `AlreadySubmitForm` si le formulaire a déjà été traitée, donc il suffit de l'écrire telle quelle dans la méthode de traitement.    

<a name='utilisationduncaptcha'></a>

## Utilisation d'un captcha dans le formulaire

Pour “protéger” un formulaire, on peut ajouter un captcha, qui pour le moment se résume à une addition simple dont il faut fournir le résultat.

Pour utiliser ce captcha :

Ajouter dans le formulaire :

~~~ruby

  app.fields_captcha
  # champ hidden contenant la valeur cryptée
  # + question
  # + champ pour répondre à la question
~~~

Puis à la soumission du formulaire, traiter la validité du captcha grâce à la méthode :

~~~ruby

  app.captcha_valid?[ <captcha>]
  # => True si le captcha est valide

~~~

Si `&lt;captcha>` n'est pas fourni, il est pris dans `param :captcha`.


<a name='dimensionsdeuxcolonnes'></a>

## Dimensions des colonnes de libellé et de value

On peut utiliser les classes suivantes pour définir la largeur de la colonne des libellés (colonnes gauche) et la colonne des valeurs (colonnes droites) où seront placés les champs d'édition (ou autre).

Le principe du nom du sélecteur est le suivant : les deux premiers chiffres correspondent au pourcentage de place pour la colonne des libellés et les deux chiffres suivant correspondent au pourcentage de largeur pour la colonne des valeurs.

    Selector CSS    Largeur     Largeur
                    libellés    Champs
    dim5050          50%         50%
    dim4060          40%         60%
    dim3070          30%         70%
    dim2080          20%         80%

*Note : En réalité, le total ne fait pas 100%, pour tenir compte des paddings et autres décalages. La somme est calculée sur 95%*.

*Note 2 : C'est dans le fichier `forms.sass` que sont définis ces styles.*

<a name='requerirmethodespratiques'></a>

## Requérir les méthodes pratiques

Au début de la vue, placer :

    site.require 'form_tools'

Cela chargera des méthodes pratique qui permettront de définir facilement les formulaires en utilisant des méthodes-raccourcis :


    form.field_text("<libelle>", "<propriété>", "<value>"[, options])

Si aucun préfixe n'est défini (cf. [Définir un préfix pour NAME et ID](#definirunprefixpourlesnameetid)) alors `NAME` et `ID` vaudront `propriété`.


## Méthodes de construction des champs {#methodesdechamp}

### Bouton de soumission {#submit_button}

    form.submit_button('<bouton name>')

### Construction d'une description

    form.field_description("<la description du champ>")

Ça n'est pas à proprement parler un champ d'édition, c'est un texte explicatif qui est placé — souvent en dessous du champ — pour le décrire.

### Construction d'un input-text

    form.field_text(<libelle>, <propriété>, <valeur def>, <options>)

Par exemple :

    <% form.prefix = "voyage" %>
    ...
    <%= form.field_text("Durée", 'duree', 10, {class: 'short'} )

Produira :

    <div class="row">
      <span class="libelle">Durée</span>
      <span class="value">
        <input type="text" name="voyage[duree]" id="voyage_id" value="10" class="short" />
      </span>
    </div>

### Construction d'un champ hidden

    form.field_hidden(nil, '<prop>', <value | nil>)

### Construction d'un textarea

    form.field_textarea(<params>)

### Construction d'un menu select

    form.field_select( <params> )

### Construction d'une case à cocher unique

    form.field_checkbox( <params> )

Noter que pour la case à cocher, le libellé (premier argument) servira de label. Il n'y aura donc pas de libellé, sauf explicitement indiqué dans les options (4e argument)

### Construction d'un ensemble de cases à cocher

    form.field_checkbox( <param> )

La différence par rapport à la case unique se fera à la définition des `values` dans le paramètres `options`, qui contiendra plusieurs valeurs au lieu d'une seule. La valeur par défaut, également, si elle est définie, sera un Array (liste des cases cochées) plutôt qu'une valeur unique.

<a name='optionspourleschamps'></a>

## Options pour les champs

    :class                  Class CSS à ajouter au champ d'édition quel
                            qu'il soit
    :row_class              Class CSS à ajouter au div.row contenant la
                            rangée du formulaire.
    :text_after             Texte à placer après le champ (dans un span)
    :text_before            Texte à placer avant le champ (dans un span)
    :libelle_width          Largeur en pixels des libellés (100 par défaut)
                            Note : Ça ne définit pas le style, mais la classe
                            wLARGEUR (par exemple w100 par défaut). Donc il
                            faut une largeur existante
    :placeholder            Le placeholder du champ pour un champ de texte
                            Rappel : le "placeholder" sera le texte qui apparaitra
                            si le champ est vide. Il indique en général le
                            contenu attendu pour le champ.
    :confirmation           Si true, le champ est "doublé" pour présenter
                            un champ de confirmation (par exemple pour un
                            mail). Noter que le libellé sera construit à partir du libellé du champ à confirmer auquel sera ajouté, devant "Confirmation de" (le libellé sera capitalisé). Par exemple, si le champ s'appelle "Votre mail", le champ de confirmation aura pour libellé "Confirmation de votre mail".


<a name='definirunprefixpourlesnameetid'></a>

## Définir un préfix pour NAME et ID


On peut définir au début le préfixe qui permettre de définir les `id` et les `name` :

    form.prefix = "<le préfixe>"

Par exemple :

    Si prefix = "user"
    Et propriété = "name"
    Alors le champ aura :
      name  = "user[name]"
      id    = "user_name"

<a name='mettreneexerguedeschamps'></a>

## Mise en exergue des champs

Deux types d'exergues sont possibles : simple, en bleu et error, en rouge. Pour mettre en exergue des champs, il suffit de fournir la liste des propriétés respectivement aux méthodes :

    form.exergue_fields = [... liste.....]
    form.error_fields   = [... liste ....]

Par exemple, on ajoute à l'url une liste de champs à exerguer à l'aide de `exfields=nom,prenom,adresse`. Dans le fichier ERB qui construit le formulaire, on ajoute :

    site.require 'form_tools'

    form.exergue_fields = (param(:exfields) || "").split(',')

C'est tout ! Les champs "nom", "prenom" et "adresse" seront automatiquement mis en exergue.

Pour une erreur sur les mêmes champs :

    site.require 'form_tools'
    form.error_fields = (param(:errfields)||"").split(',')

<a name='definitiondunobjet'></a>

## Définition de l'objet édité ou du hash de données

On peut définir l'objet du formulaire par :

    form.objet = <l'objet>

… où l'objet est soit un `Hash` de données (dont les clés sont les clés des champs) soit un objet, une instance, qui possède des méthodes-propriétés pour les champs définis.
