# encoding: UTF-8
=begin

Ce module définit toutes les féminines à ajoutées à des textes grâce aux méthodes :

    f_<ajout si féminin>

Par exemple :

    "Vous êtes censé#{f_e} faire ceci"

Ces méthodes ont plusieurs modes d'utilisation :
  * en tant que **fonctions** qui s'appliquent à l'utilisateur courant
  * en tant que **méthode** des instances User

Donc, si on trouve la fonction `f_e' dans un texte quelconque, elle renverra
un résultat en fonction de l'utilisateur courant ou du user traité.

Mais si on doit appliquer le texte à un utilisateur spécifique (par exemple dans un
listing d'Icariens où on doit écrire "Il/Elle suit le module etc."), alors on
utilisera la méthode d'instance :

    <user>.f_e

OBSOLÈTE : Noter que pour fonctionner correctement, on a ajouté à User la méthode #cu qui
faire référence à `self' dans l'instance User mais fait référence à `current_user'
dans le programme.
MAINTENANT: c'est ici qu'on fait un test plus précis pour déterminer si les méthodes
sont appelées en tant que fonction ou en tant que méthode.

PRINCIPES DE NOMMAGE

  Le principe de nommage adopté est que la méthode commence toujour par
  "f_" (comme "féminine") et est suivi de la version **féminine** de la
  féminine. Par exemple, on utilise `f_elle' pour il/elle, PAS `f_il'.
  On respecte la casse. `f_elle' retournera "elle", `f_Elle' retournera
  "Elle".

=end
module ModuleFeminines

  def feminine?
    if self.respond_to?(:identified?)
      # => méthode d'user
      femme?
    else
      user.femme?
    end
  end


  # 1 LETTRE
  def f_e # censé/censée
    @f_e ||= (feminine? ? 'e' : '')
  end
  def f_x # heureux/heureuse
    @f_x ||= (feminine? ? 'se' : 'x')
  end

  # 2 LETTRES
  def f_ne # icarien/icarienne
    @f_ne ||= (feminine? ? 'ne' : '')
  end
  def f_te # cet/cette
    @f_te ||= (feminine? ? 'te' : '')
  end
  def f_ve # attent<f> / attent(ve) et veu<f> / veu<ve>
    @f_ve ||= (feminine? ? 've' : 'f')
  end

  def f_la # le/la
    @f_la ||= (feminine? ? 'la' : 'le')
  end
  def f_La # Le / La
    @f_La ||= f_la.capitalize
  end

  # 3 LETTRES
  def f_lle # personne[l] / personne[lle]
    @f_lle ||= (feminine? ? 'lle' : 'l')
  end

  # 4 LETTRES
  def f_iere # prem[ier] / prem[ière]
    @f_iere ||= (feminine? ? 'ière' : 'ier')
  end
  alias :f_ier :f_iere
  def f_elle
    @f_elle ||= (feminine? ? 'elle' : 'il')
  end
  def f_Elle
    @f_Elle ||= (feminine? ? 'Elle' : 'Il')
  end

  def f_trice # lec<teur> / lec<trice>
    @f_rice ||= (feminine? ? 'trice' : 'teur')
  end

  def f_egve # bref/brève
    @f_rice ||= (feminine? ? 'ève' : 'ef')
  end

end
include ModuleFeminines
