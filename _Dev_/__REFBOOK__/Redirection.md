## Redirections

Pour rediriger (vraiment) sur une autre page, on utilise la méthode `redirect_to(<route>)`.

Mais noter que **cette méthode ne peut pas être appelée depuis une page ERB**, elle doit absolument être invoquée avant qu'une page ERB ne soit en construction.

C'est assez simple à gérer : quand on appelle `monObjet/home.erb`, il suffit de mettre la redirection dans `monObjet/home.rb` lui correspondant.
