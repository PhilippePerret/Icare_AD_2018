# encoding: UTF-8
class Console
class Aide
class << self

  def analyse
    p = CGI::escape './lib/modules_optional/console/console_aides/analyse.rb'
    linkmodify = "Modifier ce fichier".in_a(href:"site/open_file?path=#{p}&app=Atom")
    console.sub_log( <<-CODE)
<div class='small right'>
 #{linkmodify}
</div>
<pre>
---------------------------------------------------------------------
  AIDE ANALYSE DE FILM
---------------------------------------------------------------------

OBTENIR LA LISTE DES FILMS

    $> list films

    Note : Ça n'est pas la liste des films du filmodico qu'on
    obtient par `list filmodico`.

AFFICHER UNE ANALYSE

    Utiliser la commande :

    $> affiche analyse xxxxx

    Où "xxxx" peut être une portion du titre, du titre français
    ou de l'identifiant.

MODIFIER LES OPTIONS D'UN FILM ANALYSÉ

    Dans une fenêtre console :
    $> list films

    Repérer l'ID du film à modifier, puis, dans une autre
    fenêtre :
    $> site.require_objet 'analyse'
    $> FilmAnalyse::table_films.update( &lt;FILM ID>, {options: "&lt;NEW VALEUR>" })

    Note : Cette opération est nécessaire pour pouvoir consulter ou
    publier l'analyse du film.

AJOUTER UN FILM ANALYSÉ

    Pour ajouter un film analysé, il suffit de modifier sa valeur
    `options` (cf. ci-dessus) en mettant son premier nombre à 1
    Régler aussi le second signe pour qu'il dise le degré de visu
    de l'analyse (0 = non visible, 9 = terminée, à partir de 5 =
    lisible).

    ATTENTION : S'assure que le film définisse bien son `sym` et que
    le fichier HTML de l'analyse porte bien ce sym comme affiche
    de nom de fichier.

OBTENIR LE LIEN VERS UNE ANALYSE

  Dans la console, taper :

  $> lien|balise analyse <portion du titre>

OBTENIR LE LIEN VERS UN FICHIER D'UNE ANALYSE

    Note : Seulement pour les analyses MYE (pas TM)

    IL suffit d'afficher l'analyse (par exemple en utilisant la
    commande plus haut) puis de cliquer le bouton &lt;lien&gt;
    à côté du lien “Ouvrir” du titre de la page (plusieurs pages
    par analyse) pour obtenir différentes version du lien vers
    le fichier/la section courant/e.

    Rappel : Quand on consulte une analye de type MYE, elle est
    constituée d'une longue page sur laquelle sont rassemblés
    tous les fichiers qui la constitue, suivant le fichier
    tdm.yaml

OBTENIR LE LIEN VERS UNE PARTIE D'UNE ANALYSE

    Note : Seulement pour les analyses MYE (pas TM)

    * S'identifier comme administrateur (pour obtenir toutes les
      sortes de liens),
    * Charger l'analyse voulue (par exemple en utilisant la commande
      ci-dessus),
    * Rejoindre la section voulue
    * En face du titre doit se trouver un bouton &lt;lien&gt; qui
      affiche les formes de liens pour rejoindre la partie en
      question.

    Note : Si c'est pour un fichier Markdown, le mieux est la
    version “MARKDOWN” du lien.

</pre>
    CODE
    ""
  end

end # / << self
end #/Aide
end #/Console
