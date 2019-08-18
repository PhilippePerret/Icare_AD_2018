if(undefined==window.Frigo){window.Frigo={}}
$.extend(window.Frigo,{
  toggle_mask:function(discussion_id){
    if($('input[type="hidden"][name="masked_discussions"]').length==0){return}
    var div_dis = $('div#discussion-'+discussion_id);
    div_dis.toggle();
    var is_visible = div_dis.is(':visible');
    this.set_interlocuteur(discussion_id, is_visible);
    // cf. N0003
    var maskeds = $('input[type="hidden"][name="masked_discussions"]')[0].value;
    if (maskeds == ''){maskeds = []}
    else{maskeds = maskeds.split('-')}
    if(is_visible){
      offset = maskeds.indexOf(""+discussion_id);
      maskeds.splice(offset,1);
    }else{maskeds.push(discussion_id)}
    maskeds = maskeds.join('-');
    // Dans tous les champs hidden des formulaires
    $('input[type="hidden"][name="masked_discussions"]').val(maskeds)
  },

  // Méthode réglant l'interlocuteur
  set_interlocuteur:function(dis_id, visible){
    var pseudo_interloc = $('div#interlocuteurs span#pseudo-'+dis_id);
    if(visible){pseudo_interloc.removeClass('as_masked')}
    else{pseudo_interloc.addClass('as_masked')}
    var btn_toggle = $('a#btn_toggle_discussion-'+dis_id);
    btn_toggle.html(visible?'masquer':'afficher');
  },

  // Au chargement de la page, on masque toutes les discussions qui
  // doivent l'être et on règle les boutons des interlocuteurs
  set_masked_discussions:function(){
    if($('input[type="hidden"][name="masked_discussions"]').length==0){return}
    var maskeds = $('input[type="hidden"][name="masked_discussions"]')[0].value;
    if(maskeds != ''){
      maskeds = maskeds.split('-');
      var i=0, dis_id;
      for(i;i<maskeds.length;++i){
        dis_id = maskeds[i];
        $('div#discussion-'+dis_id).hide();
        this.set_interlocuteur(dis_id, false);
      }
    }
  }
});


$(document).ready(function(){
  Frigo.set_masked_discussions();
});
