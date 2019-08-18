/**
  * Module Flash.js
  * Flash version 2.0
  * ---------------
  * Affichage des messages utilisateur
  *
  * Requis
  * ------
  *   > La feuille de style flash.css
  *   > Un div <div id="flash"></div> dans la page
  * Notes
  * -----
  *   - Dans cette version, il est inutile de mettre un div#flash dans la
  *     page (mais s'il s'y trouve, on n'y touche pas)
  *   - Régler la position du message pour qu'il s'affiche à l'endroit voulu dans
  *     la feuille de style flash.css (div#flash)
  */
window.Flash = {
  /** Temps d'affichage maximal du message
    * @property {Number} DUREE_UTIMER (en secondes)
    */
  DUREE_UTIMER  : 2*60,
  /** Indique si l'interface a été préparé
    * @property {Boolean} prepared
    * @default False
    */
  prepared : false,
  /** Options par défaut
    * @property {Object} default_options
    */
  default_options : {keep:true,timer:true,type:'notice'},
  /** Code HTML du message à afficher
    * @property {Array} mess_code
    */
  mess_code: null,
  /** Timestamp de l'effaçage prévu du message
    * @property {Number} expire_time
    * @default Null
    */
  expire_time:null,
  /** Pointeur Timeout universel
    * @property {Number} utimer
    * @default Null
    */
  utimer: null,

  /* ---------------------------------------------------------------------
      Public methods
     ---------------------------------------------------------------------*/
  /** Affiche un message (notice)
    * @method message
    * @param {String} mess    Le message à afficher
    * @param {Object} options Les options d'affichage
    * @return {Boolean} True
    */
  message:function( mess, options )
  {
    this.show(mess, options);
    return true;
  },
  /** Affiche une erreur
    * @method error
    * @param {String} mess    Le message d'erreur à afficher
    * @param {Object} options Les options d'affichage
    * @return {Boolean} False
    */
  error: function( mess, options )
  {
    if('undefined'==typeof options){options = {};}
    this.show( mess, $.extend(options, {type:'error'}));
    return false;
  },

  /* ---------------------------------------------------------------------
      Private methods
     ---------------------------------------------------------------------*/

  /** Affiche le message
    * ------------------
    * @method show
    * @param {String} mess      Le message à afficher
    * @param {Object} options   Les options d'affichage
    */
  show:function(mess, options){
    if(false == this.prepared){this.prepare();}
    this.define_all_options(options);
    this.build_code_message( mess );
    this.append_message();
  },

  /** Nettoie la fenêtre de message
    * @method clean
    * @param {String} fct_str     La fonction appelante, pour le débug
    * @param {Integer} tps_timer   Défini si la méthode est appelée par un timer. Permet
    *                             de savoir s'il faut fader ou vider directement.
    */
  clean:function(fct_str, tps_timer){
    if('undefined' != typeof tps_timer)
    {
      this.clear_timers();
      $('#flash').fadeOut(null,function(){$(this).html("");});
    }
    else
    {
      $('#flash').html('').hide();
    }
  },

  /** Définit toutes les options d'affichage en fonction de celles
    * transmises et des options par défaut et les met dans this.options
    * @method define_all_options
    * @param {Object} options   Les options transmises
    */
  define_all_options:function(options)
  {
    if ('undefined' == typeof options){options = $.extend({}, this.default_options);}
    else
    {
      if(undefined == options.timer){options.timer  = true && this.default_options.timer;}
      if(undefined == options.keep) {options.keep   = true && this.default_options.keep;}
    }
    this.options = options ;
    return options;
  },

  /** Préparation de l'interface
    * @method prepare
    */
  prepare:function()
  {
    if($('div#flash').length == 0){$('body').append('<div id="flash"></div>');}
    this.prepared = true;
  },
  /* ---------------------------------------------------------------------
      Méthodes de traitement des messages
     ---------------------------------------------------------------------*/
  /** Insert les messages dans la page
    * Et lance le timer si nécessaire
    * @method append_message
    */
  append_message: function(){
    var oflash = $('#flash') ;
    if ( $('#inner_flash').length > 0){
      $('#inner_flash')[this.options.keep ? 'append' : 'html']( this.mess_code ) ;
    } else {
      oflash.html('<div id="inner_flash">' + this.mess_code + '</div>');
    }
    if(false == oflash.is(':visible')) oflash.fadeIn();
    this.run_required_timer();
  },
  /** Définit le code HTML exact du message
    * @method build_code_message
    * @param {String} mess  Le message
    */
  build_code_message: function( mess ){
		if('string'!=typeof mess){ return }
    mess = mess.replace(/\\("|')/g,'$1');
    this.mess_brut = mess;
    mess = mess.replace(/\n/g, '<br />' );
    this.mess_code = '<div class="flash '+this.options.type+'">'+mess+'</div>';
  },

  /* ---------------------------------------------------------------------
       Méthodes de gestion du timer
     --------------------------------------------------------------------- */

  /** = Main =
    * Lancement du timer requis
    * @method run_required_timer
    */
  run_required_timer:function()
  {
    // return ; // pour régler les couleurs
    this.clear_timers();
    this._duree_lecture = null;
    this[this.options.timer?'run_timer':'run_utimer']();
  },

  /** Détruit les timers courant
    * @method clear_timers
    */
  clear_timers:function()
  {
    if(this.timer){ clearTimeout(this.timer); delete this.timer;}
    if(this.utimer){clearTimeout(this.utimer);delete this.utimer;}
    this.expire_time = null;
  },

  /** Lance le timer universel
    * Note : Seulement s'il est supérieur au temps d'extinction du message ou
    *        s'il n'y a pas de timer de fin
    * @method run_utimer
    */
  run_utimer: function(){
    var duree = this.DUREE_UTIMER * 1000 ;
    var expire_time_utimer = this.now() + duree ;
    if((this.expire_time || 0) < expire_time_utimer)
    {
      this.utimer = setTimeout($.proxy(Flash.clean, Flash, 'run_utimer', duree), duree ) ;
    }
  },

  /** Lance le timer d'extinction du message
    * Définit également `this.expire_time' qui définit le temps d'expiration
    * d'un ou de messages précédents.
    * Note : La méthode tient compte du faire qu'il y avait peut-être un précédent
    *        temps d'expiration. Dans ce cas, elle ajoute la durée de lecture du
    *        message courant pour définir le nouveau timeout (le précédent a forcément
    *        été détruit avant l'appel de cette méthode).
    * @method run_timer
    */
  run_timer: function(){
    if( this.expire_time == null ){this.expire_time = this.now()}
    this.expire_time += this.duree_lecture();
    var real_timeout = this.expire_time - this.now();
    this.timer = setTimeout($.proxy(Flash.clean, Flash, 'run_timer', real_timeout), real_timeout) ;
  },

  /** Timestamp de maintenant
    * @method now
    * @return {Number} Timestamp
    */
  now:function(){return (new Date()).getTime();},

  /** Retourne la durée de lecture du message ajouté
    * @method duree_lecture
    */
  duree_lecture:function()
  {
    if(undefined == this._duree_lecture){this.calc_duree_lecture_mess()}
    return this._duree_lecture;
  },

  /** Calcule le temps de lecture du message courant (ou affiché si rechargement page)
    * @method calc_duree_lecture_mess
    * @return {Number} Nombre de MILLISECONDES pour la lecture du message
    */
  calc_duree_lecture_mess: function(){
    this._duree_lecture = parseInt( (this.get_mess_brut().length * 1000) / 6 ) ;
    if(this.options.type == 'error') this._duree_lecture = this._duree_lecture * 2 ;
  },

  /** Retourne le message brut
    * Note: Soit pris dans le message envoyé à la fonction, soit pris dans
    *       la page quand c'est un rechargement avec message
    * @method get_mess_brut
    * @return {String} Les messages sans balise HTML
    */
  get_mess_brut:function()
  {
    if(null==this.mess_brut)
    {
      /* Rechargement de la page */
      this.mess_brut = "";
      if($('#inner_flash').length){this.mess_brut = $('#inner_flash').html().replace(/<([^>]*>)/g, '');}
      this.options.type = $('div#inner_flash div.error').length ? 'error' : 'notice';
    }
    return this.mess_brut;
  },

  /** Méthode appelée au rechargement de la page, pour lancer
    * un timer si nécessaire.
    * @method on_load_page
    */
  on_load_page:function()
  {
    if($('#inner_flash').length == 0){return}
    this.options = {keep:false, timer:true, type:null/*sera défini plus tard*/}
    this.run_required_timer();
  }
}
window.F = Flash; // raccourci
// Flash.on_load_page() ; // timer éventuel sur le message affiché
