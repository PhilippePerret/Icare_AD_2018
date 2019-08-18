# Validation de l'inscription

Ce processus procède à la validation de l'inscription d'un user. Cette validation consiste simplement :

* SOIT à attribuer un module à l'user
* SOIT à le refuser en précisant le motif du refus.

## Nouveau mode de candidature

Maintenant, l'inscription se fait dans un dossier qui porte l'adresse :

    ./tmp/signup/<numéro de session>/

Le numéro de session, qui était la session de l'user au moment où il s'inscrivait, est enregistré en data du watcher.

Ce dossier contient :

    identite.msh      Les données de l'user pour l'inscription
    documents.msh     Les données des documents, un hash qui contient
                      les clés :presentation, :motivation et :extrait avec
                      en valeur le nom des documents (pour l'extension)
    modules.msh       La liste des identifiants des modules choisis

    documents         Dossier contenant les documents de présentation
                      Note : ces documents ne font plus l'objet d'un
                      enregistrement comme icodument.
                      Leurs noms, d'autre part, sont uniformisés, seule
                      l'extension du document original a été conservé.
