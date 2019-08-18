if(undefined==window.AbsModule){window.AbsModule={}}
$.extend(window.AbsModule,{
  set_action_choix_module: function(form){
    var modid = $('select#select_absmodule_id').val();
    console.log("modid = "+ modid);
    $(form).attr('action', 'abs_module/'+modid+'/edit');
    form.submit();
  }
})
