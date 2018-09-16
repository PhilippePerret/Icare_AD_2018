/*
 *  Objet Selection
 *  ---------------
 *  Gestion de la sélection courante
 *
 */
window.Selection = {

  /*
   *  Retourne les données de sélection du DOM Element +obj+
   *
   *  @param  obj   DOM Element ou set jQuery
   *
   */
  of:function(obj)
  {
    obj = $(obj)[0] ;
  	var t     = obj.value
  	var start = obj.selectionStart
  	var end   = obj.selectionEnd
  	return {content	:	t.substring(start, end), start:	start, end:	end };
  },
  /**
    * Retourne le texte autour de la sélection
    * @method around
    * @usage  :  Selection.around(<obj>, <params>)
    * @param {jQuerySet|DOMElement} obj   L'objet DOM
    * @param {Object} params  Paramètres définissant ce qu'il faut remonter
    *   @param  {Boolean} before    Si True (par défaut), le texte avant la sélection
    *   @param  {Number}  length    La longueur de texte qu'il faut prendre.
    *   @param {RegExp}   upto      Expression régulière du caractère non compris
    *                               jusqu'auquel il faut lire.
    * @return {Object} contenant {content:le texte, start:début, end: fin}
    */
  around:function(obj, params)
  {
    obj = $(obj)[0] ; // Pour être sûr d'avoir un élément DOM
  	var t     = obj.value
  	var start = obj.selectionStart
  	var end   = obj.selectionEnd
    if(undefined == params.before) params.before = true
    if(params.before)
    {
      end = parseInt(start,10)
      if(params.upto){
        start = -1 + end;
        for(; start >= 0; --start){
          if (params.upto.test(t.charAt(start)) ) break ;
        }
        start += 1 ;
      } else {
        start -= params.length
      }
    }
    else
    {
      start  = parseInt(end,10)
      end   += params.length
    }
  	return {content	:	t.substring(start, end), start:	start, end:	end };
  },

  /*
   *  Sélectionne dans +obj+ d'après les données fournies
   *  par +dselection+
   *
   *  @param  obj     {DOMElement} ou {jQuerySet}
   *  @param  dsel    {Hash} définissant `start' et `end'
   */
  select:function(obj, dsel)
  {
    obj = $(obj)[0] ;
    obj.focus() ;
    var start = dsel.start || dsel.at ;
    var end   = dsel.end || (start + dsel.length)  ;
  	obj.setSelectionRange(start, end ) ;
  },

  /**
    * Met la sélection courante de l'objet +obj+ à la valeur +value+
    * et place le curseur et la nouvelle sélection en fonction des
    * valeur de +options+.
    *
    * @method set
    * @param  obj     {DOM Element|set jQuery} Objet visé
    * @param  value   {String} Pour le moment, seulement un code HTML
    *                 Si contient `_$_', le dollar sera remplacé par
    *                 le texte actuel.
    * @param {Hash} Options pour l'insertion
    *   @param {Boolean|Number} options.end   Si TRUE, on place le curseur à la fin
    *                             Si un nombre `x` on place le curseur à x de la fin (-1 par exemple pour placer juste avant)
    *                           options.at    Pour .end ci-dessus
    *   @param {Number} options.length  Longueur de la sélection finale.
    *
    */
  set:function(obj, new_value, options)
  {
    if(undefined == options) options = {}
    obj = $(obj)[0] ; // Pour être sur d'avoir un DOM Object

    var current_scroll = obj.scrollTop

    var obj_selection = Selection.of(obj)
    var obj_value     = obj.value
    var old_from      = obj_selection.start
    var old_to        = obj_selection.end

    // Le nouveau texte
    if(new_value.indexOf('$_') > -1)
    {
      new_value = new_value.replace(/_\$_/, obj_selection.content)
    }
    var text_avant = obj_value.substring(0, old_from)
    var text_apres = obj_value.substring(old_to, obj_value.length)
    obj.value = text_avant + new_value + text_apres

    // Sélection du nouveau contenu
    var cursor ;
    var end_selection = old_from + new_value.length ;
    console.log("end_selection au tout départ : " + end_selection) ;

    if ('undefined' != typeof( options.at ) && 'undefined' == typeof( options.end )){
      console.log("options.end non défini, je prends options.at : " + options.at);
      options.end = options.at
    }
    if('undefined' != typeof options.end)
    {
      if('number' == typeof options.end) end_selection += options.end ;
      console.log("cursor réglé avec options.end") ;
      cursor = {in: end_selection, out: end_selection + (options.length || 0)}
    }
    else cursor = {in:old_from,      out:end_selection}
    console.log("cursor:");console.log(cursor);
  	obj.setSelectionRange(cursor.in, cursor.out) ;
	  obj.focus();
  	obj.scrollTop = current_scroll ;

  },

  get:function()
  {
    return window.getSelection()
  },

  data:function()
  {

  }

}
