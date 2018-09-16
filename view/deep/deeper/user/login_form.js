if(undefined == window.User){ window.User = {} }
$.extend(window.User,{
  /**
    * Méthode appelée juste avant de soumettre le formulaire
    * d'identification pour savoir s'il a été correctement
    * rempli.
    */
  check_login:function(){
    F.clean();
    if($('input#login_mail').val() == "" || $('input#login_password').val() == ""){
      F.error("Il faut entrer votre mail et votre code secret !");
      return false;
    } else {
      return true ;
    }

  }
})
