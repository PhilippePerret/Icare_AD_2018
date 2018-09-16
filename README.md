# Version 2018 de l'atelier Icare

Version établie à partir du modèle RestSite développé pour la WriterToolbox

Les + de cette version :

* Utilise ma base de framework RestFull, donc très pratique
* Utilise mon nouveau système de test qui permet d'écrire par exemple (sans DSL) :

      La feuille a pour titre "Page d'accueil"

      La feuille contient le message "Mon message d'adieu"

      Benoit clique le bouton 'OK', in:'form#mon-formulaire'

      La feuille contient le formulaire( 'id-du-form', in: 'section#masection',
        success: "Oui, il contient bien ce formulaire")

      La feuille ne contient pas de message erreur "Vous avez commis une erreur"

      etc.
