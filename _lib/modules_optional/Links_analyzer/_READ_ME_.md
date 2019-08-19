# Links Analyzer

* [Todo list](#todolist)
* [Lancer l'analyseur dans le Terminal](#lanceranalyseurdansterminal)
* [Lancer l'analyseur dans TextMate](#lancerdanstextemate)
* [Lancer l'analyseur dans Atom](#lanceranlyserfromatom)

Ce module est destiné à vérifier que tous les liens de toutes les pages du site sont valides et renvoient à des pages existantes et valides.

Cette opération peut se faire sur le site local comme sur le site distant.

Comme l'opération peut être longue (elle prend une dizaine de minute pour tester 1500 liens de pages de différentes tailles), on l'appelle forcément de façon isolée, de préférence par le Terminal.

<a name='todolist'></a>

## Todo list

* Il faudrait "isoler" LINKS ANALYZER de la boite à outils, pour pouvoir l'utiliser avec n'importe quel site, en spécifiant soit l'adresse du site, qui contiendrait un fichier de configuration à un endroit déterminé, soit avec l'adresse d'un fichier configuration dont on donnerait le path.

Il faut penser que ce fichier de configuration doit donner la base offline et la base online du site à tester.

Il faut penser aussi que ce site ne fonctionne pas forcément comme un site RESTFULL.

<a name='lanceranalyseurdansterminal'></a>

## Lancer l'analyseur dans le Terminal

C'est la formule préférée.

    # Ou prendre le path absolu du fichier main.rb

    > cd /Users/philippeperret/Sites/WriterToolbox/lib/deep/deeper/module/links_analyzer
    > ruby main.rb

<a name='lancerdanstextemate'></a>

## Lancer l'analyseur dans TextMate

* Afficher le fichier main.rb de la racine
* Jouer CMD + r

<a name='lanceranlyserfromatom'></a>

## Lancer l'analyseur dans Atom

* Afficher le fichier main.rb de la racine dans Atom
* Jouer CMD + i
