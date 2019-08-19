# encoding: UTF-8
=begin

Méthodes de gestion des erreurs

=end

# La classe d'erreur pour les erreurs non fatales mais qui doivent
# interrompre quand même le programme
# @usage
#     raise NonFatalError::new("le message", "la/redirec/tion")
#
class NonFatalError < StandardError
  attr_reader :redirection
  def initialize message, redirection = ''
    @message      = message
    @redirection  = redirection
  end
end

class Page

  # Pour avoir accès à l'erreur dans la page grâce à : page.error
  # On peut utiliser aussi pour certaines méthodes :
  #   - error_message (message)
  #   - error_backtrace
  attr_accessor :error
  attr_accessor :error_message
  attr_accessor :error_backtrace

  # Permet de consigner et de récupérer une erreur à mettre dans la
  # page plutôt que dans le flash erreur.
  # Inauguré pour les routes qui nécessitent d'être identifiées et
  # conduisent au formulaire d'identification.
  # L'erreur doit être inscrite dans un div 'error_in_page' pour ne
  # pas être considéré par LINKS ANALYZER comme des erreurs fonctionnelles.
  #
  # @usage
  #   Pour définir l'erreur : page.error_in_page '<le message d’erreur>'
  #   Pour l'insérer dans la page : <%= page.error_in_page %>
  def error_in_page err = nil
    if err.nil?
      @error_in_page != nil || ( return '' )
      @error_in_page.in_div(class: 'error_in_page')
    else
      @error_in_page = err
    end
  end

  def lien_backward
    "Revenir à la page précédente".in_a(href:(site.route.last||page.error.redirection)).in_div(class:'right')
  rescue Exception => e
    # Survient lorsque la session est expirée
    ""
  end

  def output_error error_id
    Vue.new("error_#{error_id}.erb", folder_error_for(error_id), site).output +
    lien_backward
  end

  def error_standard err
    self.error_message = err.message
    self.error_backtrace = ("(ERREUR : #{err.message})") + "\n" + err.backtrace.collect{|l| l.in_div}.join("\n")
    ( output_error 'standard' )
  end

  def error_non_fatale err
    self.error = err
    output_error 'non_fatale'
  end

  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite une identification.
  # Rappel : protégé par raise_unless_identified
  def error_unless_identified
    output_error 'unless_identified'
  end
  # {StringHTML} Retourne le code HTML à afficher lorsque
  # l'utilisateur essaie de rejoindre une section qui
  # nécessite d'être administrateur du site.
  # Rappel : protégé par raise_unless_admin
  def error_unless_admin
    output_error 'unless_admin'
  end
  # Rappel : pour une protection par `raise_unless( <condition> )`
  def error_unless_condition
    output_error 'unless_condition'
  end

  attr_accessor :message_error_not_owner
  def error_unless_owner message
    message ||= "Vous n'êtes pas le propriétaire de cette section du site, vous ne pouvez donc pas y pénétrer."
    self.message_error_not_owner = message
    output_error 'unless_owner'
  end

  def folder_error_for suffix
    pfolder = site.folder_view + 'page'
    if (pfolder + "error_#{suffix}.erb").exist?
      pfolder
    else
      # Sinon le dossier du fichier par défaut
      site.folder_error_pages
    end
  end
end
