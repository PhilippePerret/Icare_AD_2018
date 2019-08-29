/**
  |
  | Fonction permettant d'ouvrir le champ pour entrer la raison du
  | refus, si la candidature est rejetée.
  |
**/
check_module_choisi = function(watcher_id, val){
  var div_jid = "div#div_motif_refus_watcher-"+watcher_id;
  var o = $(div_jid);
  if(val == ''){o.show()}else{o.hide()}
}
