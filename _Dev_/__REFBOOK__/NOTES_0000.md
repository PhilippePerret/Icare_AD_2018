Dernière : N0004

N0001

    Maintenant, c'est sur la boite à outils qu'on peut
    consulter les pages de narration. On va essayer de se
    servir de la session pour vérifier que l'user peut visiter
    la page normalement, en envoyant dans l'url l'identifiant
    de l'user.

    Note : l'ID de la page doit correspondre au vrai identifiant
    sur la collection. Le titre doit être mis, il ne peut plus
    être récupéré.

    On envoie dans l'adresse les informations sur  l'icare afin
    de pouvoir créer son profil s'il n'existe pas. Mais seulement
    s'il est actif.


N0002

    OBSOLÈTE : Les documents d'inscription ne passent plus par le
    cycle normal, ils sont traités à part.

    On écarte tous les documents d'inscription, qu'on reconnait au
    fait que leur abs_module_id est à 0.

    Noter qu'on pourrait mettre cette condition dans la clause where,
    mais on ne sait pas si le filtre va fonctionner en Hash ou en
    String.


N0003

    Affichage des discussions dans les frigos

    Dans chaque formulaire pour répondre, on trouve un champ hidden :
    'masked_discussions' qui contient la liste des discussions qui sont
    à masquer (identifiant). Cette liste est actualisée dès que la visibilité
    d'un interlocuteur est modifié.

N0004

    Modification d'aout 2019
    À présent, au lieu d'avoir ça dans les dossiers :
      gabarit > header.css
                header.erb
                header.js
                header.sass
                footer.css
                footer.erb
                footer.sass
    On peut avoir :
      gabarit > header >  header.css
                          header.erb
                          header.js
                          header.sass
                footer >  footer.css
                          footer.erb
                          footer.sass

    Mais pour ne pas changer tous les codes, on teste pour savoir ce qui est
    envoyé. Et par exemple, on peut avoir un appel à `gabarit/header.erb` qui
    sera transformé en `gabarit/header/header.erb`.
