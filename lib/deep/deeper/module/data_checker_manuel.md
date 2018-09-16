# Data Checker Manuel

* [Description de DataChecker](#descriptionmodule)
* [Exemple complet de check](#exempledecheck)
* [Définition des checks](#definitiondeschecks)
* [Description de la propriété](#descriptiondelapropriete)
* [Traitement des erreurs](#traitementdeserreurs)

<a name='descriptionmodule'></a>

## Description du module


`DataChecker` est une classe pour simplifier les checks qui sont fait régulièrement sur des données.


<a name='exempledecheck'></a>

## Exemple complet de check

  require '.../module/data_checker.rb'

  class MaClass
    include DataChecker

    def save_donnees

      ### C'est ici ###
      result = mes_data_a_checker.check_data( datachecker_definition)
      if result.ok
        mes_data_checked = result.objet
        save mes_data_checked
      else
        # Afficher les erreurs survenues
        result.errors.each do |prop, herr|
          flash "#{herr[:err_message]} (code : #{herr[:err_code]})"
        end
      end

    end

    # Définition des checks à faire
    def datachecker_definition
      {
        name: {hname:"Le nom", type: :string, defined:true, min:3, max:255},
        age:  {hname:"L'âge",  type: :fixnum, defined:true, min:18, max:120},
      }
    end
  end


<a name='definitiondeschecks'></a>

## Définition des checks

Pour définir ce qu'il faut checker, on envoie à DataChecker un hash de la forme :

    {
      :<propriété à checker> => {<description de la propriété>}
    }

Pour la description de la propriété, cf. [description de la propriété](#descriptiondelapropriete).

<a name='descriptiondelapropriete'></a>

## Description de la propriété


    hname [OBLIGATOIRE] (pour "human name")

        Le nom humain qui sera utilisé dans les messages, avec un
        article devant. Par exemple "Le nom".
        Si non défini, le texte sera "La propriété :<propriété>"

    type [OBLIGATOIRE]

          Le type de la donnée, parmi :
          :string, :fixnum, :float, :bignum, :array, :hash, :boolean

          Type spécial :mail, checké comme un mail. On peut utiliser aussi
          {type: :string, mail: true}

    defined {TrueClass}

          Si true, la propriété doit absolument être définie dans l'objet,
          c'est-à-dire EXISTER et être NON NIL.
          Normalement, ne doit pas être false, ce qui serait idiot.

    min {Fixnum|Float}

          Si la propriété a un type :fixnum ou :bignum, il faut que sa valeur
          ne soit pas inférieur à cette valeur
          Si la propriété a un type :string, il faut que sa longueur ne soit
          pas inférieur à cette valeur

    max {Fixnum|Float}


          Si la propriété a un type :fixnum, :float ou :bignum, il faut que
          sa valeur ne soit pas supérieur à cette valeur
          Si la propriété a un type :string, il ne faut pas que sa longueur
          soit supérieur à cette valeur.

    mail {TrueClass}

        Si présent et true, la donnée doit être un mail valide.


<a name='traitementdeserreurs'></a>

## Traitement des erreurs

Les erreurs sont consignées dans le Hash `errors` du retour du check :

    result = mesdonnees.check_data(definition_checks)
    # => result.errors

C'est un `Hash` dont les clés sont les noms des propriétés et la valeur est un Hash qui contient `err_message` et `err_code` (utilisé seulement en interne pour le moment).

Par exemple :

    result.errors = {
      ma_prop: {err_message: "La propriété :ma_prop est trop longue (12 signes maximum)", err_code: 20001}
    }

On peut donc se servir de ce retour si on veut mettre les champs d'erreur en exergue, en se servant de la présence de la propriété :

    if result.errors.has_key?(<la propriété>)
      # => erreur avec cette propriété
    end
