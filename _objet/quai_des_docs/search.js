if(undefined==window.QuaiDesDocs){window.QuaiDesDocs={}}
$.extend(window.QuaiDesDocs,{

  onchoose_user_id:function(){
    $('input#qdd_cb_user_id')[0].checked = true;
  },
  onchoose_module_id:function(){
    $('input#qdd_cb_module_id')[0].checked = true;
    $('form#form_qdd').submit();
  },
  onchoose_etape_id:function(){
    $('input#qdd_cb_etape_id')[0].checked = true;
  },
  onchoose_annee:function(){
    $('input#qdd_cb_annee')[0].checked = true;
  },
  onchoose_trimestre:function(){
    $('input#qdd_cb_trimestre')[0].checked = true;
  }
})
