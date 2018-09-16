# encoding: UTF-8
class SiteHtml

  # {SuperFile} Le fichier HTML consignant les toute dernières actualités
  # pour ne pas avoir à le reconstruire chaque fois.
  #
  # Ce fichier est détruit dès qu'on ajoute une actualité
  #
  def file_last_actualites
    @file_last_actualites ||= folder_objet + 'actualite/listing_home.html'
  end


  # Pour afficher un formulaire permettant à l'icarien/ne d'écrire
  # un témoignage. Pour le moment, ce formulaire est utilisé exclusivement
  # à la fin des modules, dans l'étape 990 qui utilise le travail-type
  # 'modules/debriefing_module'
  def formulaire_temoignage user_id = nil
    user_id ||= user.id
    'Un conseil : ce témoignage étant public, prenez le temps de bien le rédiger dans un document séparé puis soumettez-le seulement lorsqu’il vous satisfait pleinement et qu’il est corrigé.'.
      in_p(class:'small italic') +
    (
      'save_temoignage'.in_hidden(name: 'operation') +
      (param(:temoignage)||'').in_textarea(name: 'temoignage', id: 'temoignage', style: 'width:96%;height:580px;padding:2em;') +
      'Enregistrer ce témoignage'.in_submit(class: 'btn btn-primary')
    ).in_form(id: 'form_temoignage', action: "overview/#{user_id}/temoignage")
  end

end #/SiteHtml
