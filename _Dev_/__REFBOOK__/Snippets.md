# Snippets

* [Snippets sur tous les textarea](#textareaavecsnippets)


<a name='textareaavecsnippets'></a>

## Snippets sur tous les textarea

Par défaut, en `OFFLINE`, tous les textarea sont gérables par les snippets et bloquent la page pour une utilisation aisée.

Mais en ONLINE, il faut forcer ce comportement en ajoutant :

    # Dans le fichier RUBY
    OFFLINE || page.add_javascript(PATH_MODULE_JS_SNIPPETS)

    # Dans un fichier javascript chargé
    $(document).ready(function(){
      if(ONLINE){UI.prepare_champs_easy_edit(tous=true)}
    });
    // Noter que ONLINE n'est défini qu'après le chargement
    // complet de la page
