'use strict'
/** ---------------------------------------------------------------------
  *   API pour la communication entre le site (dans l'iframe) et le testeur
  *
*** --------------------------------------------------------------------- */
class Interface {

  /** ---------------------------------------------------------------------
    *
    * INSTANCE
    *
  *** --------------------------------------------------------------------- */
  constructor(parentWindow /* window.parent */){
    // this.data = data
    this.parent = parentWindow
    this.receiveFromTestor = this.receiveFromTestor.bind(this)
  }

  /**
    Méthode utilisée pour envoyer un message au testeur
    Sera réceptionné par SWTInterface.onMessage
  **/
  sendToTestor(data){
    Object.assign(data, {responseTime: new Date().getTime()})
    this.parent.postMessage(data, '*')
  }

  /**
    Méthode recevant les messages du testeur (quand on utilise
    la méthode <SWTestor#sendToSite>)
  **/
  receiveFromTestor(ev){
    const data = ev.data
    this.currentData = data
    console.log("Données reçues par Interface.js :", data)

    if ( data.NotACase ) {
      // Une autre opération qu'un TCase à jouer
      data.eval && this.getEvalResult(data)
      this.sendToTestor(data)
    } else {
      // Si la propriété waitFor est définie dans les données, il
      // faut attendre la présence de cet élément avant d'exécuter le code
      // Si l'élément n'est pas trouvé après un timeout, on considère que le
      // cas est un échec
      if (data.waitFor) {
        this.waitFor(data.waitFor)
          .then(this.treateData.bind(this, data))
          .catch(this.onErrorWaitFor.bind(this))
      } else {
        this.treateData.call(this, data)
      }
    }

  }

  /**
    Méthode appelée quand une balise n'a pas été trouvée et que le
    timeout a été atteint
    Elle appelle sendToTestor pour retourner les données en signalant l'erreur
  **/
  onErrorWaitFor(err){
    console.error("TIMEOUT ATTEINT AVEC : ", err)
    Object.assign(this.currentData,{testError: `Impossible de trouver la balise ${err.tag}…`})
    this.sendToTestor(this.currentData)
  }


  treateData(data){
    console.log('-> treateData(data=)', data)

    // On traite la donnée en fonction du contexte fourni
    const treatmentMethod = `treateDataAs${data.context}`
    if ( this[treatmentMethod] instanceof Function) {
      // <= La méthode de traitement existe
      // => On l'appelle pour exécuter le traitement

      // Si un code est à évaluer directement, on l'évalue
      data.eval && this.getEvalResult(data)
      this[treatmentMethod](data)
    } else {
      // <= La méthode de traitement n'existe pas
      // => On produit une erreur système (qui doit interrompre les tests)
      console.error("Impossible de trouver la méthode de traitement `%s`", treatmentMethod)
    }
  }

  /**
    Si les données définissent la propriété `eval`, c'est un code à évaluer
    directement sur le site.
    On met le résultat dans `data.evalResult`
  **/
  getEvalResult(data){
    console.log("-> getEvalResult (un code est à évaluer)")
    var result
    if ( data.eval ) {
      try {
        // On évalue le code sur le site
        result = this.iframe.contentWindow.eval(data.eval)
        // Et on place le résultat dans la data, pour la renvoyer
        // TODO Voir quoi faire lorsque c'est du code asynchrone
        Object.assign(data, {evalResult: result, result:result})
      } catch (e) {
        console.error(e)
        Object.assign(data,{evalResult:'-system error-', error:e})
      }
    }
  }

  /** ---------------------------------------------------------------------
    *   Méthodes de traitement par contexte
    *
  *** --------------------------------------------------------------------- */

  /**
    Pour le contexte 'Report'
    Qui ne sert que pour écrire des messages de retour
    Donc on s'en retourne tout de suite
  **/
  treateDataAsReport(data){
    this.sendToTestor.call(this,data)
  }

  /**
    Pour le contexte 'Site'
    Initiée pour la commande test 'visit'
  **/
  treateDataAsSite(data){
    console.log("-> treateDataAsSite (data=", data)
    switch(data.method){
      case 'visit':
        document.querySelector('#site').src = `../${data.route}`
        break;
    }
    this.sendToTestor.call(this,data)
  }

  treateDataAsDom(data){

    console.log("Traitement de l'exécutant comme Dom avec les données :", data)

    switch(data.action){
      case 'click':
        console.log("* Click souris sur élément *")
        this.siteDocument.querySelector(data.subject).click()
        break
      case 'fill':
        console.log("* Remplissage de formulaire *")
        var form = this.siteDocument.querySelector(data.subject)
        for(var id in data.values){
          form.querySelector(`#${id}`).value = data.values[id]
        }
        break
      case 'submit':
        console.log("* Soumission du formulaire *")
        var form = this.siteDocument.querySelector(data.subject)
        var submitButton ;
        if ( data.submitButton ) {
          submitButton = form.querySelector(data.submitButton)
        } else {
          submitButton = form.querySelector('input[type="submit"]')
        }
        submitButton.click()
        break
    }

    this.sendToTestor.call(this,data)
  }

  treateDataAsDb(data){
    console.log("Traitement de l'exécutant comme Db avec les données :", data)

  }

  /**
    Méthode qui attend que la balise +tag+ soit contenu dans le site pour
    poursuivre
  **/
  waitFor(tag){
    const TIMEOUT = 5
    const LAPS    = 500
    const timeout = new Date().getTime() + TIMEOUT*1000
    return new Promise((ok,ko) => {
      this.timerWaitFor = setInterval(this.checkForTag.bind(this, tag, ok, ko, timeout), LAPS)
    })
  }

  checkForTag(tag, ok, ko, timeout){
    if ( !!this.siteDocument.querySelector(tag) ) {
      // Le tag a été trouvé
      console.log("%s trouvé", tag)
      clearInterval(this.timerWaitFor)
      delete this.timerWaitFor
      ok()
    } else if (new Date().getTime() > timeout) {
      clearInterval(this.timerWaitFor)
      delete this.timerWaitFor
      ko({tag:tag, timeout:timeout})
    } else {
      // <= Le tag n'a pas été trouvé
      // => on poursuit
      console.log("%s non trouvé", tag)
    }
  }

  get siteDocument(){
    return this.iframe.contentWindow.document
  }


  get iframe(){
    return this._iframe || (this._iframe = document.querySelector('iframe#site'))
  }
}

const swtInterface = new Interface(window.parent)
window.addEventListener('message', swtInterface.receiveFromTestor)
