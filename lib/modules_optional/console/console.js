$(document).ready(function(){
  var ot = $('textarea#console')

  ot.bind('keypress', function(e){
    switch(e.keyCode){
      case 13:
        $(this)[0].form.submit();
        e.stopPropagation();
        e.preventDefault();
        return false;
    }
  });
  ot.bind('focus', function(){$(this).removeClass('reduite')})

  // À chaque chargement on focusse à la fin du textarea pour
  // poursuivre le code. Sauf si le textarea n'a pas pu être
  // affiché ou qu'un résultat est affiché (car la console a
  // été réduite et le focus permettra de la grossir à nouveau)
  if (ot.length && $('div#special_output').html() == ""){
    ot.focus();
    var offset_end = ot.val().length;
    Selection.select(ot, {start:offset_end, end: offset_end})
  }

})
