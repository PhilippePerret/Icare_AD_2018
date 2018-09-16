window.Synchro = {
	request: null,
	target: null,   // Le bouton appelant exec_request
	row: null,

	/**
		* Synchro de tous les fichiers désynchronisés.
		* Le principe est une boucle qui passe en revue tous les fichiers
		* désynchronisés en les cliquant
		*/
	synchronize_all:function(){

		// Faut-il aussi détruire les fichiers
		var destroy_distant = !!$('input[type="checkbox"]#cb_destroy_distant')[0].checked;

		this.pour_suivre_upload = $.proxy(Synchro, 'loop_synchronize_all_upload');
		this.pour_suivre_destroy = $.proxy(Synchro, 'loop_synchronize_all_destroy')

		// On ramasse tous les boutons d'upload ou de destruction
		this.boutons_destroy = $('div#desynchronizeds div.distant a.destroy') ;
		this.boutons_upload = $('div#desynchronizeds div.distant a.upload') ;

		// On lance l'opération en boucle
		if(destroy_distant && this.boutons_destroy.length){
			// * Destruction des fichiers distants *

			// Pour la destruction, il faut supprimer la demande de confirmation
			this.no_confirmation_on_destroy = true ;
			// Lancer la boucle sur tous les boutons ramassés
			this.loop_synchronize_all_destroy();
		} else if(this.boutons_upload) {
			// S'il ne faut pas détruire les fichiers distants, il faut
			// appeler directement la méthode.
			this.loop_synchronize_all_upload();
		}
	},

	loop_synchronize_all_destroy:function(){
		if( this.boutons_destroy.length ){
			// Il y a encore des fichiers à détruire
			// Destruction de tous les distants à détruire
			var bouton = $(this.boutons_destroy.splice(0,1))
			// console.log("Destruction de "+ bouton.attr('data-path'));
			bouton.click();
		} else {
			// On a détruit tous les fichiers à détruire, on passe à
			// l'upload des fichiers
			this.loop_synchronize_all_upload()
		}
	},
	loop_synchronize_all_upload:function(){
		if( this.boutons_upload.length == 0 ) return ;
		// On simule le click sur le bouton pour uploader le fichier
		var bouton = $(this.boutons_upload.splice(0,1));
		// console.log("Upload de "+ bouton.attr('data-path'));
		bouton.click();
	},

	exec_request:function(request, ev){
		var path = this.get_path(ev) ;
		if(request=='destroy' && this.no_confirmation_on_destroy != true){
			if(false == confirm("Es-tu certain de vouloir détruire le fichier \""+path+"\"")) return ;
		}
		this.request = request;
		Ajax.send({request: request, path: encodeURI(path), onreturn: $.proxy(Synchro,'after_exec_request'), url:$('input#ajax_url').val()})
	},
	after_exec_request:function(rajax){
		if(rajax.success){
			switch(this.request){
			case 'destroy':
				this.row.remove() ;
				// S'il y a une méthode pour suivre la destruction, comme quand
				// on lance la synchronisation automatique complète
				if('function' == typeof this.pour_suivre_destroy){ this.pour_suivre_destroy() }
				break;
			default:
				this.row.find('a').remove() ;
				this.row.removeClass('err').addClass('ok') ;
				// S'il y a une méthode pour suivre la destruction, comme quand
				// on lance la synchronisation automatique complète
				if('function' == typeof this.pour_suivre_upload){ this.pour_suivre_upload() }
				break;
			}
		} else {
			// En cas d'échec
		}
		// console.dir(rajax) ;
	},

	get_path:function(ev){
		this.target = $(ev.currentTarget) ;
		this.row = this.target.parent().parent() ;
		return this.row.find("div.col.fname").html() ;
	}
}
$(document).ready(function(){
	Ajax.url = $('input#ajax_url').val() ;
	$('body a.download').bind('click', $.proxy(Synchro, 'exec_request', 'download'));
	$('body a.upload').bind('click', $.proxy(Synchro, 'exec_request', 'upload'));
	$('body a.destroy').bind('click', $.proxy(Synchro, 'exec_request', 'destroy'));
})
