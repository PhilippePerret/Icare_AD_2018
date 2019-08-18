if(undefined == window.Bureau){window.Bureau = {}}
$.extend(window.Bureau, {

  nombre_work_fields: 0,
  // Méthode ouvrant les champs de fichiers (jusqu'à 5)
  add_work_field:function(){
    if(this.nombre_work_fields < 5){
      this.nombre_work_fields ++ ;
      var o = $('div#form_work_file_'+this.nombre_work_fields);
      if(o.is(':visible')){return this.add_work_field()}
      else{o.show()}
      $('input#btn_send_work').removeClass('invisible');
    }else{
      F.error("Vous avez atteint le nombre maximum de champs.");
    }
  }
})
