if(undefined==window.Database){window.Database={}}
$.extend(window.Database,{

  /**
    * Méthode principale qui permet de définir l'opération et
    * de soumettre le formulaire
    *
    */
  set_op_and_submit:function(operation, options, rajax){
    if( undefined == rajax ){
      $('pre#mysql_result').html('');
      var online;
      if($('input#cb_online').length){
        online = $('input#cb_online')[0].checked ? '1' : '0';
      }else{
        online = '0';
      }
      var request = {
        route:      'database/edit',
        operation:  operation,
        dbname:       $('select#database').val(),
        tblname:      $('select#database_table').val(),
        request:      $('input#database_request').val(),
        pure_mysql:   $('input#cb_pure_mysql_code')[0].checked ? 'on' : '',
        filter:       $('input#request_filter').val(),
        columns:      $('input#request_columns').val(),
        online:       online,
        sens_synchro: $('select#sens_synchro').val(),
        onreturn:     $.proxy(Database,'set_op_and_submit', operation, options)
      }
      if(undefined!=options){
        if(options.confirmed){
          request.confirmed = '1'
        }
      }
      Ajax.send(request);
      $('div#div_db_tools').hide();

    }else{
      // Retour Ajax
      // En général, rien à faire, si ce n'est afficher le résultat
      // (le message s'affiche automatiquement)
      $('pre#mysql_result').html(rajax.mysql_result);
      // Il peut y avoir des formulaires ou des champs d'édition, donc il
      // faut observer certaines valeurs.
      UI.auto_selection_text_fields();
    }
  },

  /**
    * Méthode appelée quand on choisit une base de données
    * dans le menu des bases. Cela peuple automatiquement (et par
    * ajax) le menu des tables.
    */
  onchoose_base:function(rajax){
    if(undefined==rajax){
      Ajax.send({
        route:      'database/edit',
        operation:  'get_table_list',
        dbname:     $('select#database').val(),
        onreturn:   $.proxy(Database,'onchoose_base')
      })
    }else{
      // Retour Ajax
      // console.log(rajax.tables);
      var tables = rajax.tables.split(' ');
      var menu    = $('select#database_table') ;
      menu.html('');
      for(var i=0,len=tables.length;i<len;++i){
        var table = tables[i];
        menu.append('<option value="'+table+'">'+table+'</option>')
      }
      this.hide_outils_table();
    }

  },
  //onchoose_base


  /**
    * Méthode appelée pour savuer les données d'une rangée éditée
    */
  save_edited_row: function(rajax){
    if(undefined == rajax){
      Flash.show("Je passe ici");
      Ajax.submit_form('form_edit_row', $.proxy(Database,'save_edited_row'))
    }else{
      // Retour ok, normalement
    }
  },

  /**
    * Pour confirmer la synchronisation
    *
    */
  confirm_synchronisation:function(){
    this.set_op_and_submit('synchronize', {confirmed: true})
  },
  /**
    * Méthode appelée quand on veut détruire entièrement une table
    *
    */
  want_drop_table: function(){
    // Confirmation
    var tbl = $('select#database').val() + '.' + $('select#database_table').val();
    if(confirm("Êtes-vous sûr de vouloir détruire la table "+tbl+" ?")){
      if(confirm("Cette destruction détruira définitivement toutes les données !")){
        this.set_op_and_submit('remove_table')}
    }

  },

  /**
    * Méthode appelée quand on veut vider une table
    */
  want_empty_table: function(){
    var tbl = $('select#database').val() + '.' + $('select#database_table').val();
    if(confirm("Êtes-vous sûr de vouloir effacer toutes les données de la table "+tbl+" ?")){
      if(confirm("Toutes les données vont être détruites, peut-être à jamais si vous n'avez pas fait de backup.")){
        this.set_op_and_submit('empty_table')
      }
    }
  },

  on_change_filter: function(){
    var val = $('input#request_filter').val();
    if(val == ''){
      nom_bouton = 'Afficher le contenu';
    }else if(!isNaN(parseInt(val,10))){
      nom_bouton = 'Afficher/éditer la rangée #' + val;
    }else{
      nom_bouton = 'Afficher le contenu filtré';
    }
    this.set_name_of_btn_afficher_content(nom_bouton)
  },

  // Pour régler le nom du "bouton-lien" pour afficher le contenu
  set_name_of_btn_afficher_content:function(value){
    $('a#btn_afficher_content').html(value)
  },

  /**
    * Méthode appelée quand on choisit une table
    * Cela affiche le block des outils de table (div_table_tools)
    */
  onchoose_table:function(){
    this.show_outils_table();
    $('input#request_filter').val('');
    $('input#request_columns').val('');
  },

  show_outils_table:function(){
    $('div#div_table_tools').css({'display':'inline-block'});
    $('div#div_db_request').show();
  },
  hide_outils_table:function(){
    $('div#div_table_tools').css({'display':'none'});
    $('div#div_db_request').hide();
  },

  /**
    * Affiche l'aide dont l'ancre est +ancre+
    *
    * La méthode s'assure que le manuel soit bien ouvert, l'ouvre le cas
    * échéant et scroll jusqu'à la partie voulue.
    */
  aide:function(ancre){
    $('div#manuel').show();
    UI.scrollTo('a[name="'+ancre+'"]');
  }


})

$(document).ready(function(){
  Database.hide_outils_table();
})
