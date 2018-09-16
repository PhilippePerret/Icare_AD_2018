if(undefined==window.AbsTravailType){window.AbsTravailType={}}
$.extend(window.AbsTravailType,{

  // Méthode appelée quand on modifie les liens
  // Elle crée les liens pour les voir
  onchange_liens:function(){
    var val = $('textarea#wtype_liens').val().trim();
    if(val == ''){
      liens_formated = '';
    }else{
      var liens = val.replace(/\r/g,'').split("\n");
      var liens_formated = '';
      for(var i=0,len=liens.length;i<len;++i){
        var dlien = liens[i].split('::');
        if (dlien[1] == 'collection'){
          href  = 'www.laboiteaoutilsdelauteur.fr/narration/'+dlien[0]+'/show';
          titre = dlien[2] || ('Page narration #' + dlien[0]);
        }else{
          href = dlien[0];
          titre = dlien[1];
        }
        liens_formated += '<div><a href="http://'+href+'" target="_new">'+titre+'</a></div>';
      }
    }
    $('div#liens_formated').html(liens_formated);
  },

  // Méthode appelée quand on définit une nouvelle rubrique.
  // Elle met le menu des rubriques à rien
  ondefine_new_rubrique:function(){
    $('form#form_edit_wtype select#wtype_rubrique').val('');
  },

  // Méthode appelée quand on vide le champ ID ou qu'on clique sur
  // le bouton 'new'
  onreset_id:function(valeur){
    if(valeur == ''){
      var fields = [
        'rubrique', 'short_name', 'new_rubrique',
        'id', 'titre', 'objectif', 'travail', 'methode', 'liens'
      ]
      $(fields).each(function(i, fd){
        $('form#form_edit_wtype #wtype_'+fd).val('')
      })
    }
  }
})

// Quand la page est chargée
$(document).ready(function(){

  // On met en forme les liens éventuels
  AbsTravailType.onchange_liens();

  if(ONLINE){UI.prepare_champs_easy_edit(tous=true)}

})
