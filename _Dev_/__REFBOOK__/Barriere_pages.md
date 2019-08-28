# Barrière pages

* [Pages accessibles par les icariens](#pageaccessiblesparicariens)


Les barrières-pages empêchent d'atteindre certaines pages lorsqu'on ne remplit pas les conditions voulues.

<a name='pageaccessiblesparicariens'></a>

## Pages accessibles par les icariens

C'est par exemple le cas de la page `home` (`./_objet/user/home.erb`).

Il faut mettre au-dessus du fichier `.rb` :

    raise_unless (user.icarien? || user.admin?), nil, true

Le 3e argument, `true`, permet d'envoyer au formulaire d'identification. Cela peut être utile lorsque l'icarien rejoint une page de son bureau par exemple depuis un lien, ou lorsque sa session a expiré et qu'il recharge son bureau ou autre.
