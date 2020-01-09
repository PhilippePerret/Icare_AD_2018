/**
  Ce script est un exemple de test à utiliser avec SiteWeb-Testor
  https://github.com/PhilippePerret/WebsiteTestor.git
**/

const DATA_PHIL = require('../data/secret/data_phil.json')

it("Identification d'un icarien")
// Il faudrait s'assurer qu'aucune session ne soit connectée
visit('user/login')
tag('a#signout-button').not.exists()
tag('H1').contains("S’identifier")
tag('form#form_user_login')
  .fillWith({login_mail:DATA_PHIL.mail, login_password:DATA_PHIL.password})
  .andSubmit()
tag('a#signout-button').exists()
tag('div#flash').contains("Bienvenue, Phil")
