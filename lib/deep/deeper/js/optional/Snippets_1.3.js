/**
  * Objet Snippet
  * -------------
  * Gestion des Snippets.
  * Author: Philippe Perret
  * cf. le fichier Snippet_manual.md
  */

const SCOPES = {
  // Toujours chargé
  'core':{
    // Un faux snippet, pour obtenir l'aide sur les snippets
    // actifs.
    'help': {replace: ''}
  },
  // Liste des snippets pour le code HTML
  'text.html': {
    'a' :   { replace: '<a href="$1">$2</a>$0'},
    'p' :   { replace: "<p>$0</p>"},
    'pid':  { replace: '<p id="$1">$0</p>'},
    'pclass': {replace: '<p class="$1">$0</p>'},
    'pidc':   {replace: '<p id="$1" class="$2">$0</p>'},
    'div' : { replace: '<div class="$1">$2</div>$0'},
    'pre' :   { replace: "<pre>\n$0\n</pre>"},
    'span': { replace: '<span id="$1" class="$2">$3</span>$0' },
    'divp': { replace: "<div class='p'>$1</div>$0"},
    'em':   { replace: "<em>$1</em>$0"},
    'b':    { replace: "<b>$1</b>$0"},
    'dl':   { replace: "<dl>\ndt$0\n</dl>"},
    'dt':   { replace: "<dt>$1</dt>\ndd$0"},
    'dd':   { replace: "<dd>$0</dd>"},
    'h1':   { replace: "<h1>$1</h1>$0"},
    'h2':   { replace: "<h2>$1</h2>$0"},
    'h3':   { replace: "<h3>$1</h3>$0"},
    'h4':   { replace: "<h4>$1</h4>$0"},
    'ul':   { replace: "<ul>\n  li$0\n</ul>"},
    'li':   { replace: "<li>$1</li>$0"},
    'c':   { replace: "<code>$1</code>$0"},
    'code':   { replace: "<code>$1</code>$0"}
  },
  'text.erb':{
    '#':    { replace: "<%# $0 %>" },
    '---':  { replace: "-----------------------------------------------------------------------"},
    '%':    { replace: "<%$1 %>$0" },
    '=':    { replace: '<%= $1 %>$0' }
  }
}

if(undefined == window.Snippets){ window.Snippets = {}}
$.extend(window.Snippets, {
  // Quand le snippet n'est pas trouvé, on remplace la tabulation par le texte
  // défini ci-dessous.
  // NON: Ça pose trop de problèmes avec la gestion des différentes positions
  // ensuite
  // REPLACEMENT_ON_TAB: "  ",

  // Méthode à exécuter au retour chariot (if any)
  ON_RETURN: null,
  // Méthode à exécuter quand on frappe CMD + Retour chariot
  ON_CMD_RETURN: null,

  // Si on veut définir des méthodes à appeler lorsque
  // des touches modificatrices sont appelées.
  ON_META_KEY: null,
  ON_CTRL_KEY: null,
  ON_ALT_KEY : null,

  //Snippets définis pour le champ actif
  data_snippets: null,
  // Instances {Snippet} actifs. En clé, le champ, en
  // valeurs l'instance
  snippets: new Object,
  // Pour définir le ou les scopes
  set_scopes_to:function(arr_scopes){
    var all_data_snippets = {} ;
    var my = this;
    var the_scope ;
    if('string' == typeof arr_scopes){
      var l = [];l.push(arr_scopes); arr_scopes = l;
    }
    $.each(arr_scopes, function(i, required_scope){
      if(typeof required_scope == "string"){
        the_scope = SCOPES[required_scope] ;
      } else {
        the_scope = required_scope ;
      }
      if('object' == typeof the_scope) $.extend(all_data_snippets, the_scope) ;
      else { F.error("Le scope "+required_scope+" devrait être un objet définissant les snippets.") }
    })
    // On ajoute toujours les snippets faisant partie du 'coeur', mais
    // en dernier pour qu'ils puissent être surclassés par les snippets
    // introduits
    $.extend(all_data_snippets, SCOPES.core) ;
    this.data_snippets = all_data_snippets ;
  },

  /**
    * Méthode appelée de l'extérieur pour surveiller un
    * champ
    */
  watch: function(jid){
    if(!this.annonce_help_already_displayed){
      F.show("Utiliser le snippet 'help' pour obtenir la liste complète des snippets courants.");
      this.annonce_help_already_displayed = true ;
    }
    $(jid).bind('keypress', $.proxy(Snippets,'on_keypress',jid))
  },
  unwatch:function(jid){
    $(jid).unbind('keypress', $.proxy(Snippets,'on_keypress',jid)) ;
  },
  watch_multiselect:function(jid){
    $(jid).bind('keydown', $.proxy(Snippets,'on_keydown', jid)) ;
    $(jid).bind('keypress', $.proxy(Snippets,'on_keypress_multiselect',jid)) ;
  },
  unwatch_multiselect:function(jid){
    $(jid).unbind('keydown', $.proxy(Snippets,'on_keydown', jid)) ;
    $(jid).unbind('keypress', $.proxy(Snippets,'on_keypress_multiselect',jid)) ;
  },
  // On se sert de cette méthode pour consigner l'offset de
  // fin de la sélection actuel, cas dans on_keypress, peut-être
  // parce qu'on est entre deux évènements, il est toujours égal
  // à zéro
  on_keydown: function(jid,evt){
    this.current_offset_in_jid = evt.currentTarget.selectionEnd ;
  },
  /**
    * Fonction principale.
    * Exécute la recherche de snippets sur le champ +jid+
    */
  on_keypress: function(jid, evt){
    if(evt.metaKey  && this.ON_META_KEY){ return this.ON_META_KEY(evt)}
    if(evt.ctrlKey  && this.ON_CTRL_KEY){ return this.ON_CTRL_KEY(evt)}
    if(evt.altKey   && this.ON_ALT_KEY){  return this.ON_ALT_KEY(evt)}
    switch(evt.keyCode){
    case 9:
      this.current_field = $(jid)[0] ;
      this.exec(jid) ;
      return false ;
    case 13:
      if (evt.metaKey && this.ON_CMD_RETURN){
        this.ON_CMD_RETURN();
        return false;
      } else if( this.ON_RETURN ){
        this.ON_RETURN();
        return false;
      }
      break;
    // default:
    //   // log(evt.keyCode);log(evt.metaKey)
    }
    return true ;
  },
  /**
    * Quand c'est un snippet à multiple sélections, on
    * attend la tabulation suivante pour sélectionner
    * le texte suivant.
    */
  on_keypress_multiselect:function(jid, evt){
    if(evt.keyCode != 9) return true ;
    this.snippets[jid].next_selection() ;
    return false ;
  },

  exec:function(jid){

    // On initialise un nouveau snippet même si ça n'en est
    // pas un.
    // Rappel : Cette méthode est appelée dès que l'utilisateur
    // utilise la touche tabulation donc rien ne dit qu'il s'agit
    // d'un vrai snippet.
    var snip = new Snippet({jid: jid});

    // Si le trigger ne correspond pas à un snippet, alors on a deux
    // solution : soit la constante REPLACEMENT_ON_TAB est définie et on
    // insert ce texte au curseur, soit on donne une alerte à l'utilisateur
    // Dans les deux cas on s'en retourne.
    if( snip.is_not_a_snippet ){
      snip.error_not_a_snippet();return false
    }

    if( snip.trigger == 'help' ){
      // Cas particulier de l'aide : on doit afficher tous les
      // snippet courant
      // Noter qu'on poursuit quand même pour effacer le 'help'
      // qui a été écrit dans le champ d'édition
      try{this.affiche_help_current_snippets()}
      catch(error){F.error("Impossible d'afficher la liste des snippets : "+error)}
    }
    // On remplace le trigger par le texte approprié et on attend
    // que l'utilisateur définisse les variables-dollar ou autre.
    snip.replace_and_wait() ;

    return false ; // pour ne pas prendre en compte la tabulation
  },

  affiche_help_current_snippets:function(){
    if($('pre#aide_snippets').length == 0){
      var aide_text = [] ;
      console.dir(this.data_snippets);
      for(k in this.data_snippets){
        v = this.data_snippets[k]['replace'].replace(/</g,'&lt;').replace(/\n/g, '\\n');
        if (v.length > 30){v = v.substring(0, 30)}
        while(k.length < 10){k = ' ' + k}
        aide_text.push( k + " : " + v );
      }
      aide_text = aide_text.join("<br>");
      aide_code =
        '<pre id="aide_snippets" style="z-index:500;max-height:500px;overflow:scroll;font-size:11.4pt;background-color:black;color:white;padding:1em;position:fixed;top:1.5em;left:1.5em">' +
          '<div class="bold" style="margin-bottom:1em">LISTE DES SNIPPETS COURANTS</div>' +
          aide_text +
          '<div class="right small"><a onclick="$(\'pre#aide_snippets\').hide()">[Fermer]</a></div>' +
        '</pre>';
      $('body').append(aide_code);
    }else{
      $('pre#aide_snippets').show();
    }
  }

});

/**
  * Classe Snippet
  * --------------
  # Pour la gestion des snippets.
  */
window.Snippet = function(data){
  this.id                     = Snippet.new_id() ;
  this.jid                    = data.jid ;
  this.dom_owner              = $(data.jid)[0] ;
  Snippet.list[this.id]       = this ;
  Snippets.snippets[this.jid] = this ;
}
$.extend(Snippet, {
  // Liste de tous les snippets créés
  list: [],
  // Dernier ID pour un snippet
  last_id: 0,
  // Retourne un nouvel ID pour un nouveau snippet
  new_id:function(){
    this.last_id ++ ;
    return this.last_id ;
  }
})
window.Snippet.prototype = {
  // Méthode qui remplace le trigger par le texte du snippet et
  // attend que l'utilisateur entre le texte si nécessaire.
  // Rappel : Il existe trois situations possibles :
  //  1.  C'est un snippet sans variable-dollar ($). Dans ce cas, on
  //      peut s'arrêter tout de suite.
  //  2.  C'est un snippet avec une seule variable dollar ($0). Dans ce
  //      cas, on attend l'entrée de l'utilisateur.
  //  3.  C'est un snippet avec plusieurs variables-dollar. Dans ce cas,
  //      Il faut brancher l'élément DOM sur un autre gestionnaire
  //      d'évènements clavier pour gérer les différentes variables
  //      dollar pour pouvoir bien les sélectionner.
  // Note : La méthode procède aussi à l'analyse du texte remplacement
  // pour savoir quoi sélectionner.
  replace_and_wait:function(){
    // On doit d'abord sélectionner le trigger
    this.select_trigger() ;
    // Ensuite, on le remplace par le texte du snippet
    this.replace_selection_content_with( this.text ) ;
    // Si une aide est définie et que le div #snippets_help existe, alors
    // on doit afficher l'aide pour ce snippet (qui permet la plupart du
    // temps de définir les valeurs attendues dans les variables dollar)
    this.affiche_help_if_needed() ;
    // On doit ensuite sélectionner ce qu'il faut.
    this.first_selection() ;
  },
  affiche_help_if_needed:function(){
    // Pas d'aide si le div#snippets_help n'existe pas
    if($('#snippets_help').length == 0){ return }
    $('#snippets_help').html( this.help || "" ) ;
  },
  // Méthode permettant de sélectionner le trigger du
  // snippet.
  select_trigger: function(){
    this.dom_owner.setSelectionRange(this.offset, this.offset + this.trigger.length) ;
  },
  // Méthode permettant de passer à la première sélection.
  // Il faut revenir au décalage initial, car le :offset de la
  // première sélection correspond au décalage du premier $1 ou
  // de $0.
  first_selection: function(){
    this.set_selection_to({start: this.offset, end: this.offset}) ;
    switch( this.selections.length ){
      case 0 :
        // Cas d'un snippet sans variable dollar.
        // On place le curseur à la fin de l'insertion du snippet.
        var end_of_insert = this.offset + this.text.length ;
        this.set_selection_to({ start: end_of_insert }) ;
        break ;
      case 1 :
        break ;
      default :
        // Plusieurs sélections
        Snippets.unwatch( this.jid ) ;
        Snippets.watch_multiselect( this.jid ) ;
        break ;
    }
    this.next_selection() ;
  },
  // Méthode permettant de passer à la sélection suivante
  // si elle existe. Dans le cas où elle n'existe pas, on
  // termine le snipper
  next_selection: function(){
    var nsel = this.selections.shift() ;
    if( undefined == nsel ){
      // Quand il n'y a plus de sélections
      if( this.has_multi_variables_dollar ){
        Snippets.unwatch_multiselect( this.jid ) ;
        Snippets.watch( this.jid ) ;
      }
      return false ;
    } else {
      // Quand il y a une sélection, on doit calculer le
      // :start et le :end à envoyer à set_selection pour que
      //  la sélection soit bonne. Ils correspondront à la position
      // de départ à laquelle s'ajoutera le :offset défini dans nsel
      // et la longueur de la sélection.
      var start = this.dom_owner.selectionStart + nsel.offset ;
      var end   = 0 + start + nsel.length ;
      var specs_selection = { start: start, end: end }
      this.set_selection_to( specs_selection ) ;
      return true ;
    }
  },
  // Méthode qui définit le texte de la sélection dans le
  // propriétaire DOM du snippet en le mettant à +replacement+
  // Noter que la méthode ne va faire que remplacer le texte qui
  // est sélectionné (ou le simple curseur).
  replace_selection_content_with: function( replacement ){
    var o = this.dom_owner ;
    var current_scroll = o.scrollTop ;
    var o_selection = Selection.of(o) ;
    var o_value     = o.value ;
    var old_start   = o.selectionStart ;
    var old_end     = o.selectionEnd ;
    var text_avant  = o_value.substring(0, old_start) ;
    var text_apres  = o_value.substring(old_end, o_value.length) ;
    // On met la nouvelle valeur
    o.value = text_avant + replacement + text_apres ;
  },
  // Méthode permettant de définir la sélection
  // +params+ doit définir :start et :end. Si :end n'est pas
  // défini, on prend la valeur de :start (pas de sélection).
  set_selection_to:function( params ){
    if(undefined == params.end) params.end = params.start ;
    this.dom_owner.setSelectionRange(params.start, params.end) ;
  },
  // Méthode appelée si le snippet n'a pas de trigger connu,
  // donc si ça n'est pas vraiment un snippet.
  error_not_a_snippet:function(){
    Flash.show("`" + this.trigger + "` n'est pas un snippet connu.");
    return false ;
  },
  get_selections: function(){
    var snip = "".concat( this.text ) ;
    var resultats = new Array();
    var rest_snip = "" ;
    var found, str_found ;
    while( (found = snip.match(/\$[0-9]/)) != null ){
      str_found = found[0] ;
      resultats[str_found] = found.index + rest_snip.length ;
      rest_snip = rest_snip.concat(snip.substring(0, found.index + 1)) ;
      snip = snip.substring(found.index + 1, snip.length) ;
    }
    selects = new Array() ;
    var last_offset = 0 ;
    for( var i = 1; i < 10; ++i ){
      var key     = "$"+i ; // pour le moment
      var offset  = resultats[key] ;
      if( undefined != offset ){
        selects.push({offset: offset - last_offset, length: key.length}) ;
        last_offset = 0 + offset + key.length ;
      }
    }
    if(undefined != resultats['$0']){
      selects.push({offset: resultats['$0'] - last_offset, length: 2});
    }

    // On définit la propriété du snippet pour savoir s'il a
    // plusieurs variables-dollar définies.
    this.has_multi_variables_dollar = selects.length > 0 ;

    // log("selects:");log(selects);
    return selects ;
  }
}
Object.defineProperties(Snippet.prototype,{
  // Méthode qui retourne la liste des offsets des sélections
  // dans le cas où c'est bien un snippet.
  // Les "sélections" correspondent aux variables-dollar du
  // texte du snippet, qu'on va passer en revue pour permettre
  // à l'utilisateur de les définir.
  // RETURN un Array de { :start, :end }
  selections:{
    get:function(){
      if(undefined == this._selections){ this._selections = this.get_selections() }
      return this._selections ;
    }
  },
  // Retourne TRUE si le snippet est vraiment un snippet,
  // ce que l'on ne sait pas à l'instanciation du snippet.
  is_snippet:{
    get:function(){
      return undefined != this.data ;
    }
  },
  is_not_a_snippet:{ get:function(){return ! this.is_snippet} },

  // Les données du snippet
  data:{
    get:function(){
      if(undefined == this._data) this._data = Snippets.data_snippets[this.trigger] ;
      return this._data
    }
  },
  // Le texte de remplacement
  text:{ get:function(){ return this.data.replace } },
  // Le texte d'aide à afficher (if any)
  help:{get: function(){return this.data.help} },

  // Décalage du trigger donc du texte de remplacement aussi.
  // La valeur est calculée lorsque l'on fait appel à la propriété
  // `trigger'
  offset:{
    get:function(){return this._offset}
  },
  // {String} Propriété contenant le mot juste avant le cursor
  // Note : la méthode `get` permet aussi de définir l'offet du
  // snippet (décalage dans le texte juste avant le trigger)
  trigger:{
    get:function(){
      if(undefined == this._trigger){
        var o = this.dom_owner ;
        var t = o.value ; // contenu du champ
        var end = parseInt( o.selectionStart ) ;
        // L'expression régulière qui va permettre de chercher
        // le premier caractère qui ne peut pas faire partie
        // d'un snippet.
        var upto = new RegExp('[^a-zA-Z0-9\._\%\=\-]') ;
        // On va commencer en testant le caractère juste avant
        // la position du curseur puis remonter jusqu'à trouver
        // un caractère non snippetisable.
        for(var start = (-1 + end); start >= 0; -- start){
          // On s'arrête dès qu'on a trouvé un caractère qui ne
          // peut pas faire partie d'un snippet.
          if(upto.test(t.charAt(start))) break ;
        }
        this._char_before_trigger = t.substring(start, start+1) ;
        this._trigger = t.substring(start + 1, end) ;
        this._offset  = parseInt(start + 1) ;
      }
      return this._trigger ;
    }
  },
  char_before_trigger:{
    get:function(){return this._char_before_trigger}
  }
})
