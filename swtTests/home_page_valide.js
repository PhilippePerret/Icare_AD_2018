/**
  Test de la validité de la page d'accueil
**/
it("Validité de la page d'accueil")
visit('/')
tag('body').exists()
tag('section#header_home').exists()
tag('section#header_home div.common-tools').exists()
tag('a#overview-button').exists()
tag('a#signup-button').exists()
tag('a#login-button').exists()
