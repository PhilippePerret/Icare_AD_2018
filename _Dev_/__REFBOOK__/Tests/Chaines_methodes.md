# Chaines méthodes

* [Méthodes pour les formulaires](#methodestestformulaire)
* [Méthodes de test pour les mails](#methodesdetestsmails)
* [Les messages](#lesmessages)
  * [Message flash (notice)](#messageflash)
  * [Message d'erreur flash](#messagederreurnoramle)
  * [Message d'erreur fatal](#messagederreurfatail)


<a name='methodestestformulaire'></a>

## Méthodes pour les formulaires

    La feuille contient le formulaire '<form id>'
    La feuille contient le bouton '<nom bouton>', dans: '<form ou autre>'

    La feuille ne contient pas derreur

    Lui clique le bouton '<nom bouton>'
    Lui clique le link '<nom bouton>'
    Lui coche la checkbox '<label du checkbox ou name ou id>'

    Lui remplit le champ '<référence>', <Hash args>

        args peut contenir
          :dans/:in       JID du contenant, le formulaire par exemple
          :avec/:with     La valeur à mettre dans le champ
          :qui            Le pseudo éventuel de l'utilisateur
          :success        Le message de succès if any
          :failure        Le message d'échec, if any


# ---------------------------------------------------------------------

<a name='methodesdetestsmails'></a>

## Méthodes de test pour les mails

~~~

  Phil recoit le mail <Hash data mail>[,
    success: '<message de succès>']

~~~

~~~

  Benoit recoit le mail <Hash data mail>

~~~

Si c'est un autre user qui doit être utilisé, il faut l'instancier de cette manière pour qu'il puisse être un `Someone` de test.

~~~

  def Lui chaine
    Someone.new({user_id: <id>, pseudo: '<son pseudo>'}, chaine).evaluate
  end

~~~

Puis on l'utilise normalement :

~~~

  Lui recoit un mail <data>

~~~


Pour les mails, il faut initialiser un `Someone` avec l'identifiant de l'utilisateur :

    def Newu chaine
      Somenone.new({user_id: @<id du user>}, chaine).evaluate
    end
    # Penser que @<id du user> doit être accessible, donc soit une
    # méthode soit une variable d'instance.

Puis on peut appeler la méthode :

    data_mail = { .... }
    Newu recoit le mail data_mail


<a name='lesmessages'></a>

## Les messages

<a name='messageflash'></a>

### Message flash (notice)

    La feuille affiche le message "<le message>"

    La feuille n affiche pas le message "<le message>"

<a name='messagederreurnoramle'></a>

### Message d'erreur flash

    La feuille affiche le message erreur "<le message>"

    La feuille n affiche pas le message erreur "<le message>"

    La feuille ne contient pas derreur

        On peut spécifier en argument le message de succès ou d'échec.
        Pour le message d'échec, on peut utiliser `%{erreurs}` pour écrire
        les messages d'erreur trouvés dans la page.

<a name='messagederreurfatail'></a>

### Message d'erreur fatal

    La feuille affiche le message fatal "<le message>"

    La feuille n affiche pas de message fatal
