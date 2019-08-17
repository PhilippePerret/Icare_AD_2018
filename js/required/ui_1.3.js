if(undefined == window.UI){window.UI={}}
$.extend(window.UI,{

  /**
    * Pour scroller jusqu'à l'élément +jid+ de façon douce
    *
    * @usage : UI.scrollTo('balise#identifiant')
    */
  scrollTo: function(jid, vitesse, addtotop){
    if(undefined == vitesse){vitesse = 500}
    if(undefined == addtotop){addtotop = 100}
    $('html, body').animate(
      {
        scrollTop: $(jid).offset().top - addtotop
      },
      vitesse);
  },
  /**
	 	* Offre un texte à copier-coller
		*
		*	+text+ 	SOIT un string (un seul texte à copier-coller)
		*					SOIT un object définissant titre1, texte1, titre2, texte2 ... titre4, texte4
    *
    * @usage
    *   UI.clip("Le code à copier-coller")
    *   UI.clip({"Titre 1": "Code 1", "Titre 2":"Code 2", etc.})
    *
    * Pour passer un lien complet <a...>, entendu qu'on ne peut pas
    * faire passer de guillemets doubles, on utilise :
    * ALINK[<le lien>, <le titre if any>]
    * Par exemple :
    *   UI.clip({"Lien":"ALINK[wwww.boa.fr]"})
    * Produira :
    *   <a href="http://www.boa.fr">www.boa.fr</a>
    *   (noter que 1/ le 'http' est ajouté s'il manque et
    *    2/ le titre reprend l'adresse)
    * Tandis que :
    *   UI.clip("Lien":"ALINK[http://www.boa.fr,La Boite à outils]")
    * produira :
    *   <a href="http://www.boa.fr">La Boite à outils</a>
    */
  clip:function(text){
    console.log(text)
    var width = text.length * 10 ;
		if ('string' == typeof text){
			//
			// Version avec un simple texte
			//
	    Flash.show(
	      "Copie-colle : " +
	      '<input id="toclip" type="text" onblur="Flash.clean()" onfocus="this.select()" value="'+text+'" style="width:'+width+'px;" />'
	    ) ;
	    $('input#toclip').select() ;
		}else {
			//
			// Version avec des données plus complexes
			//
			mess = "Copie-colle :" ;
			var titrex, textex, inputtext ;
      var i = 0
			for(var titrex in text){
				textex = text[titrex] ;
				if(textex){

          // Traitement spécial des liens (qui ne peuvent pas
          // être envoyés tel quel — lire la présentation de
          // cette méthode)
          if(textex.substring(0, 6) == "ALINK["){
            portion = textex.substring(6, textex.length-1);
            virgule_offset = portion.indexOf(',');
            if (virgule_offset < 0){href = portion; titre = portion}
            else {
              href  = portion.substring(0, virgule_offset);
              titre = portion.substring(virgule_offset+1, portion.length);
              F.show("titre = " + titre)
            }
            if(href.substring(0,4) != 'http'){href = "http://" + href}
            textex = '<a href=\"'+href+'\">'+titre+'</a>' ;
            inputtext = "<textarea rows='2' style='font-size:9pt;width:280px' onchange='Flash.clean()' onfocus='this.select()'>"+textex+'</textarea>'
          } else {
            inputtext ='<input style="width:280px" id="toclip'+i+'" type="text" onchange="Flash.clean()" onfocus="this.select()" value="'+textex+'" />' ;
          }
          mess += "<div>" +
                  '<span style="display:inline-block;width:140px;">' + titrex + '</span>' +
					        inputtext +
                 '</div>'
           ++i;
				}
			}
			mess += '<div class="italic">CMD + X puis TAB pour faire disparaitre ce dialog</div>';
			Flash.show(mess) ;
	    $('input#toclip1').select() ;
		}
  },

  // Prépare les champs input-text et textarea pour que
  // lorsqu'on focus dedans ils sélectionnent leur contenu
  // À mettre dans le $(document).ready ou lorsque du
  // code est remonté par Ajax.
  auto_selection_text_fields:function(){
    $(['input[type="text"]', 'input[type="password"]']).each(function(i, jid){
      // Au cas où…
      $(jid).unbind('focus', function(){$(this).select()})
      // On le surveille
      $(jid).bind('focus', function(){$(this).select()})
    })
  },

  // Observe tous les champs d'édition qui possède une
  // class 'warning'. Ce sont des champs mis en exergue
  // peut-être suite à une erreur ou une valeur incorrecte.
  // Quand l'utilisateur le modifie, on peut supprimer la
  // classe
  observe_champs_warning:function(){
    $(['input.warning', 'textarea.warning', 'select.warning']).each(function(i,o){
      $(o).bind('change', function(){$(this).removeClass('warning')})
    })
  },

  /** Pour initialiser les champs d'un formulaire
    * +hfields+ est un Hash pouvant contenir au choix :
    *   .val      Array des JID de champs dont la valeur (value) doit
    *             être mise à "". Ce sont les input-text, les textarea
    *   .uncheck  Array des ID (attention, pas JID) des checkbox qui
    *             doivent être décochés
    *   .check    Array des ID (attention, pas JID) des checkbox qui
    *             doivent être cochés
    *   .empty    Array des JID des champs dont le contenu (html) doit
    *             être vidé
    *   .select   Array des ID (pas JID) des menus qui doivent être
    *             remis à la valeur 0
    *   .remove   Array des JID des éléments à détruire entièrement
    */
  init_form:function(hfields){
    if(hfields.val)
      $(hfields.val).each(function(i, o){$(o).val('')});
    if(hfields.uncheck)
      $(hfields.uncheck).each(function(i,o){$("input#"+o)[0].checked = false});
    if(hfields.check)
      $(hfields.check).each(function(i,o){$("input#"+o)[0].checked = true});
    if(hfields.empty)
      $(hfields.empty).each(function(i,o){$(o).html('')});
    if(hfields.select)
      $(hfields.select).each(function(i,o){$('select#'+o)[0].selectedIndex = 0});
    if(hfields.remove)
      $(hfields.remove).each(function(i,o){$(o).remove()});
  }


})
