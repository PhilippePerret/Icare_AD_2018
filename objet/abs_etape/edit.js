if(undefined==window.AbsEtape){window.AbsEtape={}}
$.extend(window.AbsEtape,{

  // Méthode appelée quand on choisit une étape dans le menu
  // supérieur
  // Elle définit l'action du formulaire avant de le soumettre
  onchoose_etape:function(){
    var form = $('form#form_module_etape');
    var abs_etape_id = $('select#menu_etapes').val();
    form.attr('action', "abs_etape/"+abs_etape_id+"/edit");
    console.log('route : ' + "abs_etape/"+abs_etape_id+"/edit");
    form.submit();
  },
  onchoose_module:function(){
    var form = $('form#form_module_etape');
    form.attr('action', "abs_etape/edit")
    form.submit();
  },
  // Méthode appelée quand on modifie les liens
  // Elle crée les liens pour les voir
  onchange_liens:function(){
    var val = $('textarea#etape_liens').val().trim();
    if(val == ''){
      liens_formated = '';
    }else{
      var liens = val.replace(/\r/g,'').split("\n");
      var liens_formated = '';
      for(var i=0,len=liens.length;i<len;++i){
        var dlien = liens[i].split('::');
        if (dlien[1] == 'collection'){
          href  = 'www.scenariopole.fr/narration/page/'+dlien[0];
          titre = dlien[2] || ('Page narration #' + dlien[0]);
        }else{
          href = dlien[0];
          titre = dlien[1];
        }
        liens_formated += '<div><a href="http://'+href+'" target="_new">'+titre+'</a></div>';
      }
    }
    $('div#liens_formated').html(liens_formated);
  }
})

// Quand la page est chargée
$(document).ready(function(){

  // On met en forme les liens éventuels
  AbsEtape.onchange_liens();

  if(ONLINE){UI.prepare_champs_easy_edit(tous=true)}

})
