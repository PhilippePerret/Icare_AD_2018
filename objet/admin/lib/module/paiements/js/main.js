var current_year = null ;

function SetDatesPreviousYear(){
  if(current_year == null){
    current_year = parseInt($('input#current_year').val())
  }else{--current_year}
  $('input#fromto_from_date').val("1/1/"+(current_year-1));
  $('input#fromto_to_date').val("1/1/"+current_year)
}
function SetDatesNextYear(){
  if(current_year == null){
    current_year = parseInt($('input#current_year').val())
  }
  // Pour passer à l'année suivante
  ++current_year;
  $('input#fromto_from_date').val("1/1/"+(current_year-1));
  $('input#fromto_to_date').val("1/1/"+(current_year))
}
