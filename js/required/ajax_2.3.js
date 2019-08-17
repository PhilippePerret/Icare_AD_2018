/**
  * @module ajax.js
  * @version 2.3
  *
  * Dépendances
  *   * Nécessite l'objet Flash pour l'affichage des messages d'erreur
  *     Doit obligatoirement retourner false (requête abandonnée) ou true
  *
  */
window.Ajax = {
	url: 			null,
  onreturn:	null,

	// Message dans le flash pendant l'opération ajax
	// Le mettre à null pour ne pas l'afficher ou le redéfinir par
	// le message propre à l'opération, grâce à :
	// Ajax.message_on_operation = "<le message opération>";
	// message_on_operation: "Opération ajax en cours…",
	message_on_operation: null,

  /**
    * Procéder à une requête ajax
    * Cf. la section Ajax dans le manuel
    * @method send
    * @param  {Hash}      data      Données à transmettre au programme serveur
    * @param  {Function}  onreturn  Méthode pour suivre
    */
  send:function( data ){
    if(this.before_send(data) == false) return;
    data.ajx = 1 ;
    this.onreturn = data.onreturn ;
    delete data.onreturn ;
		this.url = data.url || "./index.rb" ;
		delete data.url ;
		if (data.message_on_operation != undefined){
			this.message_on_operation = data.message_on_operation ;
			delete data.message_on_operation ;
		}
		// Note : Même si le message est défini ci-dessus, il peut avoir
		// été mis à null par la méthode appelante. Il faut donc faire le
		// test ci-dessous.
		Flash.clean('Ajax.send');
		if (this.message_on_operation){
			Flash.message(this.message_on_operation)
		}
    $.ajax({
      url     : this.url,
      type    : 'POST',
      data    : data,
      success : $.proxy(this.on_success, this),
      error   : $.proxy(this.on_error, this)
      });
  },
  on_success:function(data, textStatus, jqXHR){
		if(this.message_on_operation != null){Flash.clean('Ajax.on_success')}
    this.traite_messages_retour( data );
    this.traite_css_retour( data.css ) ;
    if('function' == typeof this.onreturn) this.onreturn(data);
    return true;
  },
  on_error:function(jqXHR, errStatus, error){
    if(this.message_on_operation != null){Flash.clean('Ajax.on_error')}
    Flash.error( error );
  },
  /**
    * Méthode propre à l'application pour vérfier les données ou les modifier
    * @method before_send
    * @param  {Object} data Les données envoyées à send
    * @return {Boolean} True si la requête peut se faire, false otherwise
    */
  before_send:function(data)
  {
    // var route_isnt_defined = (undefined == data.url)
    // if(route_isnt_defined){ return F.error("Les données envoyées par Ajax doivent absolument définir `url', la méthode de router à utiliser. Si c'est un champ de formulaire, ajouter le champ hidden de name 'url'.");}
    return true;
  },

  /**
		* @usage			Ajax.submit_form(<form id>, <fonction retour>)
		*
    * Pour soumettre un formulaire
    * @method submit_form
    * @param {String}   form_id   ID html du formulaire (sans "form#") OU le formulaire lui-même
    * @param {Function} fn_return [Optionnel] Fonction de retour, appelée au retour de la
    *                             soumission avec le résultat
		*
		* NOTE IMPORTANTE
		* ===============
		*		Le formulaire doit définir 'route' dans ses
		* 	champs pour être traité par le bon objet. Par exemple :
		*		'database/edit'.in_hidden(name: 'route')
    */
  submit_form:function(form_id, fn_return, route)
  {
    var form ;
    if('string' == typeof form_id) form = $('form#'+form_id);
    else form = form_id ;
    var hdata = hash($(form).serializeArray()) ;
    hdata.onreturn = fn_return ;
    this.send( hdata );
  },
  /**
    * Traitement spécial des propriétés `message' et `error' si elles
    * existent dans le retour ajax
    * @method traite_messages_retour
    * @param {Object} data    Hash retourné par le serveur
    */
  traite_messages_retour:function(data)
  {
    if('undefined' == typeof data){ return }
    if('undefined' != typeof data.message){Flash.message(data.message);delete data.message;}
    if('undefined' != typeof data.error){Flash.error(data.error);delete data.error;}
  },

  /**
    * Si les données de retour Ajax contiennent la propriété `css'
    * ce sont des feuilles de style à ajouter dans la page
    *
    */
  traite_css_retour:function(arr_css){
    if('undefined' == typeof arr_css || arr_css == null) return ;
    $.map(arr_css, function(path_css, icss){
      $('head').append("<link rel='stylesheet' type='text/css' href='"+path_css+"' charset='utf-8' />")
    })
  },
  /**
    * Les formulaires possédant l'attribut ajax="1" sont observés
    * et passent par ici. Si tout se passe bien ici, le formulaire est
    * soumis en Ajax, sinon le formulaire est soumis normalement.
    *
    * La route `r' définie dans le formulaire doit correspondre à la
    * méthode de traitement du retour Ajax. Par exemple :
    *   r = "narration/show"
    *   => que la route ruby sera la méthode 'show' de l'objet Narration
    *   => que la méthode de traitement du retour Ajax en javascript sera
    *      aussi la méthode 'show' de l'objet Narration (noter la capitale)
    *
    */
  on_submit_form:function(form){
    try {
      var arr     = $(form).serializeArray() ;
      var hdata   = hash( arr ) ;
      var droute  = hdata.r.split('/') ;
      var dreturn ;
      if('undefined' == typeof hdata.onreturn) {
        dreturn = droute ;
      } else {
        // On fonction de retour stipulée explicitement
        dreturn = hdata.onreturn ;
      }
      var objet   = dreturn[0].capitalize() ;
      var method  = dreturn[1] ;
      var fct_return = $.proxy(window[objet], method) ;
      hdata.onreturn = fct_return ;
      this.send( hdata ) ;
      return false ; // pour court-circuiter le formulaire
    } catch (err) {
      // Si une erreur s'est produite, on charge la page normalement
      // if(console) console.error( err ) ;
      F.error("Une erreur est survenue : " + err) ;
      return false ;
    }
  }
}
