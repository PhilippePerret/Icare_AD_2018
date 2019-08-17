$(document).ready(function(){

  // Un compteur sur le message qui est peut-être affiché
  // sur la page. Mais on ne le met pas si des messages
  // d'erreur sont affichés
  if($('#flash').length){
    if( $('#flash div.error').length == 0 ){
      var coefH = $('#flash').height() / 40;
      setTimeout($.proxy(Flash, 'clean', null, true), 5000 * coefH)
    }
  }

  /** Au chargement de la page, on surveille tous les champs de
    * texte de type textarea pour que, lorsqu'on focusse dedans :
    * - la page se bloque
    * - le champ s'aggrandit aux dimensions de la page
    * - les snippets html et erb sont installés
    *
    * Ça n'est fait de façon automatique qu'en OFFLINE. Sinon,
    * en ONLINE, il faut explicitement le demander.
    */
    // NOTE : ici se pose en problème lors du test Google pour qui
    // la variable OFFLINE ne semble pas définie, et est donc mise
    // à TRUE. Il faudrait explicitement la définir dans tous les
    // cas
  if('undefined'==typeof(OFFLINE)){OFFLINE = true}
  if(OFFLINE){UI.prepare_champs_easy_edit(forcer = true)}

  UI.auto_selection_text_fields();

  // Surveille tous les champs d'édition marqués "warning",
  // en général pour mettre en exergue une erreur
  UI.observe_champs_warning();

})
