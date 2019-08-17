if(undefined == window.UI){window.UI = {}}
if( 'undefined' == typeof(ONLINE) ){ ONLINE = true }

$.extend(window.UI,{

  /**
    * Pour masquer/afficher la marge gauche
    *
    */
  left_margin_on: true,
  toggle_left_margin:function(){
    var left_margin, left_padding;
    var my = window.UI;
    var section_content = $('section#content');
    afficher = my.left_margin_on == false ;
    if(afficher){
      $('section#left_margin').show();
      left_margin   = section_content.attr('data-margin-left');
      left_padding  = section_content.attr('data-padding-left');
      section_content.attr('style', null);
    } else {
      $('section#left_margin').hide();
      section_content.attr('data-margin-left', section_content.css('margin-left'));
      section_content.attr('data-padding-left', section_content.css('padding-left'));
      left_margin   = '2em' ;
      left_padding  = 0 ;
      section_content.css('margin-left', left_margin);
      section_content.css('padding-left', left_padding);
    }

    $('a#btn_mask_marge').html(afficher ? 'Masquer marge' : 'Afficher marge');

    my.left_margin_on = !my.left_margin_on;
  },

  /**
    * Méthode appelée automatiquement au chargement de toutes
    * les pages en OFFLINE qui préparent tous les champs textarea
    * de classe 'easyedit' pour faciliter leur édition :
    * Ils sont aggrandis lorsqu'on focusse dedans et la page est
    * 'bloquée'
    *
    * Pour l'utilise en ONLINE, il faut charger le module
    * snippet :
    *   page.add_javascript(PATH_MODULE_JS_SNIPPETS)
    * et appeler cette méthode dans un $(document).ready
    *
    * Il faut également appeler cette page lors de l'utilisation
    * d'ajax (lorsqu'on ajoute des éléments au DOM par ajax)
    *
    * Si +forcer+ est vrai, on force tous les textarea à réagir
    * de cette façon.
    */
  prepare_champs_easy_edit: function(forcer){
    var jid ;
    if (forcer){jid = 'textarea'}else{jid='textarea.easyedit'}
    if ($(jid).length == 0){
      // On a rien à faire s'il n'y a aucun champ de type
      // easyedit dans la page
      return;
    }

    // Le code pour rendre les textareas sensibles aux
    // Snippets
    Snippets.set_scopes_to(['text.erb', 'text.html']);
    $(jid).bind('focus',function(){
      Snippets.watch($(this));
      UI.bloquer_la_page(true);
    })
    $(jid).bind('blur',function(){
      Snippets.unwatch($(this));
      UI.bloquer_la_page(false);
    })
    this.bloquer_la_page(true);
    this.bloquer_la_page(false);

  },


  HEIGHT_TEXTAREA: '50px',

  // Tous les Jid des éléments à masquer quand la
  // fenêtre est bloquée.
  ELEMENTS2MASK_WND_BLOQUEE: [
    'section#header',
    'section#footer',
    'section#debug',
    'section#left_margin',
    'section#content > h1',
    'section#content > h2',
    'section#social_network',
    'form#taches_widget'
  ],

  /** Méthode permettant de bloquer la page, i.e. de rendre
    * la section#content fixe et de faire disparaitre les
    * éléments de page inutiles.
    * Utile pour les listes qui sont toujours embêtantes
    * à utiliser.
    *
    * De plus :
    *   - On place un bouton en haut à gauche pour débloquer
    *     la page.
    *   - On réduit tous les textarea, mais en plaçant un
    *     observateur qui va les mettre en haut à gauche
    *     dès qu'on focussera dedans et les remettra
    *     en place après au blur
    */
  bloquer_la_page:function(bloquer){
    var css_content = {}
    if(bloquer){
      css_content = $.extend(css_content, {
        'padding'     : '0'
      })
    }
    css_content = $.extend(css_content, {
      'position':(bloquer ? 'fixed' : 'relative'),
      'top':(bloquer ? '0' : 'none'),
      'left':(bloquer ? '50px' : 'none'),
      'margin-left':(bloquer ? '0' : '')
    })
    $('section#content').css(css_content);
    $(this.ELEMENTS2MASK_WND_BLOQUEE).each(function(i,e){
        if(bloquer){ $(e).hide()}
        else{$(e).show()}
    })

    if(bloquer){
      // On place un bouton pour débloquer la page
      this.bouton_debloquer();
      // On réduit les textarea et on place des observers
      $('textarea').css({
        'height': this.HEIGHT_TEXTAREA, 'max-height':this.HEIGHT_TEXTAREA,
      'min-height':this.HEIGHT_TEXTAREA});
      $('textarea').bind('focus', function(ev, ui){UI.onfocus_textarea(ev, $(this))});
      $('textarea').bind('blur',  function(ev, ui){ UI.onblur_textarea(ev, $(this))});
    } else {
      // On place un bouton pour bloquer la page
      this.bouton_bloquer();
    }

  },

  debloquer_la_page:function(){
    this.bloquer_la_page(false)
  },

  old_textarea_height:  null,
  old_textarea_width:   null,
  old_z_index: null,
  onfocus_textarea:function(ev, o){
    this.old_textarea_height = o.css('height');
    this.old_textarea_width = o.css('width');
    this.old_z_index = o.css('z-index');
    var txth = (window.innerHeight - 100) + 'px' ;
    o.css({
      'position':'fixed', top:'40px', left:'40px',
      'min-height': txth,
      'height': txth,
      'max-height': txth,
      'width': '800px',
      'z-index': '1000'
    })
  },
  onblur_textarea:function(ev, o){
    o.css({
      'position':'', top:'', left:'',
      'height':this.HEIGHT_TEXTAREA,
      'min-height':this.HEIGHT_TEXTAREA,
      'max-height':this.HEIGHT_TEXTAREA,
      'width': this.old_textarea_width,
      'z-index': this.old_z_index
    })
  },

  bouton_debloquer:function(){
    this.build_bouton_debloquer('debloquer')
  },
  bouton_bloquer:function(){
    this.build_bouton_debloquer('bloquer')
  },
  build_bouton_debloquer(pour){
    $('a#bouton_bloquer').remove();
    var btn_name = pour == 'bloquer' ? 'Bloquer' : 'Débloquer' ;
    var sty = 'position:fixed;bottom:10px;right:10px;border:1px solid #888;padding:2px 8px';
    var bouton = '<a id="bouton_bloquer" onclick="$.proxy(UI,\''+pour+'_la_page\')(true)" style="'+sty+'" class="tiny">'+btn_name+'</a>';
    $('body').append(bouton);
  }

})
