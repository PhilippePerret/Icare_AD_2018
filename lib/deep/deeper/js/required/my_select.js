/**
  * Fonction appelée lorsque l'on clique sur un menu
  * pour le rendre actif
  *
  * +ocont+ est le container du faux menu
  */
function mySelectSetActif(ocont){
}
function mySelectSetInactif(ocont){
}
/**
  * Dans un menu `my_select`, cette méthode est appelée
  * lorsque l'on choisit un menu. Elle place dans le champ
  * hidden associé la valeur choisie, qui pourra être
  * récupérée comme dans n'importe quel champ de formulaire.
  *
  * Si une méthode `onchange` est définie dans le parent,
  * cette méthode est appelée.
  */
function onChangeMySelect(odiv){
  var odiv      = $(odiv);
  var myselect  = odiv.parent();
  var contmenu  = myselect.parent();
  // Le container est-il actif ? Si c'est le cas, c'est une
  // sélection de menu. Si ça n'est pas le cas, c'est pour
  // mettre le menu en action.
  var menu_is_actif = contmenu.hasClass('actif');

  if(menu_is_actif){
    var choix = odiv.attr('value');
    // On doit récupérer le parent pour obtenir le nom
    // du champ hidden
    var myselect_id = myselect.attr('id');
    var hidden_id   = myselect_id.substring(9, myselect_id.length);
    $('input#'+hidden_id+'[type="hidden"]').val(choix);
    // Il faut mettre le 'selected' au nouveau choix
    // et retirer l'ancien
    myselect.find('> div.myoption').each(function(){
      $(this).removeClass('selected')
    })
    odiv.addClass('selected');
    // alert("Vous avez choisi le menu " + choix + "\nDans " + hidden_id)
    // Si une méthode `onchange` est appelée, il faut l'invoquer
    var methode_onchange = myselect.attr('onchange');
    methode_onchange && eval(methode_onchange)
    // Pour finir, on rend le menu inactif
    contmenu.removeClass('actif');
  }else{
    contmenu.addClass('actif');
  }

}

function placeObserverOnMySelects(){
  $('div.container_myselect div.myoption').click(function(ev){
    ev.preventDefault();
    ev.stopPropagation();
    onChangeMySelect($(this));
  })

}

$(document).ready(function(){
  placeObserverOnMySelects();
})
