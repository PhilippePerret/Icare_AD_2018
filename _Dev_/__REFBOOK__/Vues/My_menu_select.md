# Menus `My_Select`

Les menus `myselect` sont des menus qui fonctionnent par CSS et permette une meilleur stylisation.

## Implantation des menus `myselect`

On implante les menus `myselect` comme les autres, à partir d'un `Array` de paire « value - titre ». Mais au lieu d'utiliser la méthode `in_select`, on utilise `in_my_select`.

Par exemple :

~~~ruby
  [
    [val1, 'Ma première valeur'],
    [val2, 'Ma seconde valeur']
  ].in_my_select(id: 'monmenu', name: 'monmenu',
    onchange: 'maFonctionOnChange()')
~~~

## Définir la largeur du menu

On peut définir la largeur du menu en définissant `size`, qui peut prendre les valeurs `normal` (par défaut), `medium`, `long` ou `small`.

Seules ces quatre valeurs ont été définies pour offrir une cohésion de style.

## Récupérer la valeur du menu

Pour récupérer la valeur d'un menu `myselect`, il faut appeler `input#<id du menu>` et non plus `select#<id du menu>`.

Par exemple, si le menu est défini par :

~~~ruby
    menu = [...].in_my_select(id: )
~~~
