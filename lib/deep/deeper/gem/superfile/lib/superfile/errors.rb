# encoding: UTF-8
class SuperFile
  ERRORS = {
    :cant_write_a_folder  => "Impossible d'écrire dans un dossier…",
    :inexistant           => "Le fichier/dossier “%{path}” est inexistant",
    :already_exists       => "Le fichier/dossier “%{path}” existe déjà"
  }
  
  # {Array|NilClass} Errors list or NIL
  attr_reader :errors
  
  # Ajoute une erreur mais sans l'afficher
  def add_error err
    @errors ||= []
    @errors << err
    return false
  end

 
end