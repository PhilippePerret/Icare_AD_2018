if(undefined==window.TachesWidget){window.TachesWidget={}}

$.extend(window.TachesWidget,{
    
    create_tache:function(){
	F.clean();
	F.show("Enregistrement de la tâche…");
	// On met le titre de la page dans le champ de
	// formulaire hidden
	var grand_titre = $('section#content h1').first().html();
	// S'il n'y pas de grand titre, c'est qu'on doit se trouver
	// sur la page d'accueil
	if (!grand_titre){grand_titre = 'Accueil'; titre_page = null}
	else{
	    var titre_page  = $('section#content h2').first().html();
	    if(titre_page){titre_page = titre_page.trim()}
	}
	var titre = grand_titre;
	if (titre_page){ titre += "::" + titre_page }
	$('input#tache_titre_page').val( titre );
	Ajax.submit_form('taches_widget');
	// On ferme la boite des taches, pour le côté pratique autant
	// que pour empêcher qu'on clique deux fois
	$('div#inner_widget').hide();      
    }
})
