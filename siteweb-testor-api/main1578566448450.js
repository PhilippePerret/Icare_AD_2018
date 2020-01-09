'use strict'
/**
  Programme prinipal pour l'interface
**/

document.addEventListener('DOMContentLoaded', function(event) {
  console.log("La page de l'interface est prête.")

  document.getElementById('site').contentWindow.addEventListener('DOMContentLoaded', event => {
    console.log("La page du site est prête.")
    // On envoie un message à l'interface pour dire que le site est prêt
    swtInterface.sendToTestor({'firstReady':true})
  })

})
