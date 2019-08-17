# encoding: UTF-8
=begin

  Notamment la méthode TestedPage#valide? qui détermine comment
  on considère qu'une page est valide.

=end

# ---------------------------------------------------------------------

class TestedPage

  # Return TRUE si l'url testée est valide, au niveau de son
  # contenu, ou FALSE dans le cas contraire, en mettant de @errors
  # toutes les erreurs éventuelles
  #
  # Définit toutes les erreurs rencontrées
  #
  def check_if_valide_for_app
    # Éléments qu'on doit forcément trouver dans la page
    [
      'section#header', 'section#content', 'section#footer',
      'section#left_margin'
    ].each do |tag|
      if self.matches?(tag)
        true
      else
        error "TAG INTROUVABLE : #{tag}"
      end

    end #/fin de loop sur tous les éléments de base à trouver


    # === MESSAGE ERREUR ===
    # Voir si la page contient un message d'erreur, dans
    # une balise flash
    if self.matches?('div#flash div', with: {class: 'error'})
      nokogiri.css('div#flash div.error').each do |message_erreur|
        error "MESSAGE ERREUR TROUVÉ : #{message_erreur.inner_html}"
      end
    end

    # === MESSAGE INDIQUANT UNE ERREUR FATALE ===
    # Note : pour le moment, elle n'est produite que lorsqu'il
    # y a un problème avec un SuperFile pour déserber le fichier
    if self.matches?('div', with: {class: 'fatal_error'})
      nokogiri.css('div.fatal_error').each do |message_erreur|
        error "MESSAGE FATAL ERROR TROUVÉ : #{message_erreur.inner_html}"
      end
    end

    # === TEXTE INDIQUANT UNE ROUTE INTROUVABLE ===
    if self.matches?('h1', text: 'Erreur 404')
      messages_erreur = Array.new
      nokogiri.css('section#content div.air.warning').each do |meserr|
        messages_erreur << meserr.inner_html
      end
      error "ERREUR 404 : #{messages_erreur.join(', ')}"
    end

    return @errors.count == 0
  end

end
