if(undefined==window.Signup){window.Signup={}}
$.extend(window.Signup,{

  check_cgu: function(){
    if ($('input#user_accept_cgu')[0].checked) {
      return true;
    }else{
      alert('Vous devez accepter les Conditions Générales d’Utilisation (cochez la case au-dessus du bouton).');
      return false;
    }
  },
  
  check_modules:function(){
    if($('ul#abs_modules').length){
      var un_module_is_checked = false ;
      $('ul#abs_modules li.absmodule input[type="checkbox"]').each(function(){
        if(un_module_is_checked){return} /* pour accélérer */
        if($(this)[0].checked){un_module_is_checked = true}
      });
      if(false == un_module_is_checked){F.error("Vous devez choisir au moins 1 module d’apprentissage.")}
      return un_module_is_checked;
    }else{
      // Pour se prémunir d'un éventuel changement d'identifiant,
      // mais ATTENTION, la liste ne serait alors plus checkée...
      return true;
    }
  },

  /** Méthode appelée quand on soumet le formulaire avec les
    * documents de présentation. La méthode s'assure que les
    * deux documents minimums sont définis
    *
    * La méthode retourne TRUE en cas de succès, permettant de
    * soumettre le formulaire, ou FALSE en cas d'échec
    */
  check_documents:function(){
    Flash.clean();
    var valpre = $('input#signup_documents_presentation').val().trim();
    var valmot = $('input#signup_documents_motivation').val().trim();
    if(valpre == '' && valmot == ''){
      F.error('Il faut impérativement transmettre les 2 documents obligatoires (marqués d’une astérisque rouge).')
      return false;
    }else if(valpre == '' || valmot == ''){
      if(valpre == ''){F.error('Il faut impérativement transmettre votre document de présentation.')}
      else if(valmot == ''){F.error('Il faut impérativement transmettre votre lettre de motivation.')}
      return false;
    }else{
      return true;
    }
  }
})
