if(undefined==window.Watcher){window.Watcher = {}}
$.extend(window.Watcher,{
  objet: null,

  /**
    * Méthode appelée quand on choisit une valeur dans un menu
    * Cela provoque deux actions :
    *   1. On met la valeur dans le champ correspondant
    *   2. Suivant le menu, on peuple une autre valeur de menu. Par exemple,
    *      quand on choisit un objet, ça peuple le menu des processus, en
    *      mettant les processus de cet objet.
    */
  onchoose: function(select){
    select = $(select);
    var prop = select.attr('data-prop');
    var value = select.val();
    $('input#watcher_'+prop).val(value);
    // On doit récupérer les valeurs pour certains menus
    switch(prop){
      case 'objet':
        // => Liste des processus
        // => Liste des Ids pour objet_id (if anay)
        this.objet = value ;
        if(value != ''){
          this.get_and_set_processus_list();
        }
        break;
    }
  },
  // Méthode qui récupère par ajax la liste des processus
  // de l'objet courant
  get_and_set_processus_list: function(rajax){
    if(undefined == rajax){
      Ajax.send({
        route:      'watcher/edit',
        opwatcher:  'get_processus_list',
        objet:      this.objet,
        onreturn: $.proxy(Watcher,'get_and_set_processus_list')
      })
    }else{
      // Retour d'ajax
      var plist = rajax.processus_list.split(' ');
      var select_processus = $('select#menu_processus');
      select_processus.html('');
      select_processus.append('<option value="">Choisir…</option>')
      var i, pname;
      for(i=0, len=plist.length; i<len; ++i){
        pname = plist[i];
        select_processus.append('<option value="'+pname+'">'+pname+'</option>')
      }
      // On peut poursuivre
      this.get_and_set_objet_id_list();
    }
  },
  get_and_set_objet_id_list:function(rajax){
    if(undefined == rajax){
      Ajax.send({
        route:      'watcher/edit',
        opwatcher:  'get_objet_id_list',
        objet:      this.objet,
        user_id:    $('input#watcher_user_id').val(),
        onreturn:   $.proxy(Watcher,'get_and_set_objet_id_list')
      })
    }else{
      // Retour d'ajax
      var hlist = JSON.parse(rajax.objet_id_list);
      var leselect = $('select#menu_objet_id');
      leselect.html('');
      leselect.append('<option value="">Choisir…</option>')
      var i, pname;
      for(i=0, len=hlist.length; i<len; ++i){
        hobjet = hlist[i];
        var objet_id = hobjet[0] ; var objet_tit = hobjet[1] ;
        v = objet_id ;
        if(objet_tit){v += " " + decodeURIComponent(objet_tit).replace(/\+/g,' ')}
        leselect.append('<option value="'+objet_id+'">'+v+'</option>')
      }
    }
  },

  /**
    * Méthode appelée pour actualiser la liste des users
    */
  update_user_list: function(rajax){
    if(undefined == rajax){
      Ajax.send({
        route:      'watcher/edit',
        opwatcher:  'user_list',
        user_type:  $('select#type_icarien').val(),
        onreturn:   $.proxy(Watcher,'update_user_list')
      })
    }else{
      // Retour Ajax
      var user_list = JSON.parse(rajax.user_list) ;
      var select_user = $('select#menu_user_id');
      select_user.html('');
      select_user.append('<option value="">Choisir…</option>')
      var i, pname;
      for(i=0, len=user_list.length; i<len; ++i){
        udata = user_list[i];
        user_id = udata[0]; user_pseudo = udata[1];
        select_user.append('<option value="'+user_id+'">'+user_id + ' - '+user_pseudo+'</option>')
      }
    }
  }
})
