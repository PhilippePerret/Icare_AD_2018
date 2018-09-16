if(undefined == window.Dashboard){window.Dashboard = {}}
$.extend(window.Dashboard,{

  // note : DATA_OPERATIONS est défini en ruby
  on_choose_operation: function(){
    var ope = $('input#opuser_ope').val();
    // alert('Opération choisie : ' + ope);
    var data_op = DATA_OPERATIONS[ope] ;

    // Champ pour une valeur courte
    $('div#div_short_value')[data_op.short_value ? 'show' : 'hide']();
    $('div#short_value_explication').html(data_op.short_value || '');
    $('input#opuser_short_value').val('');

    // Champ pour une valeur moyenne
    $('div#div_medium_value')[data_op.medium_value ? 'show' : 'hide']();
    $('div#medium_value_explication').html(data_op.medium_value || '');
    $('input#opuser_medium_value').val('');

    // Champ pour une valeur longue
    $('div#div_long_value')[data_op.long_value ? 'show' : 'hide']();
    $('div#long_value_explication').html(data_op.long_value || '');
    $('textarea#opuser_long_value').val('');
  },

  onchoose_type_icarien:function(){
    this.reset_menu_operation();
    $('input#opuser_user_id').val('');
    $('form#form_operation_icarien').submit();
  },

  reset_menu_operation:function(){
    $('input#opuser_ope').val('');
  }
})


$(document).ready(function(){
  if(ONLINE){UI.prepare_champs_easy_edit(tous = true)}});
