# encoding: UTF-8
=begin

Méthodes pour le suivi

=end
class LaTexBook

  # Pour le message final, en cas de succès
  def message
    "Le livre #{pdf_file} a été construit avec succès."
  end

  # Pour le message final, en cas d'erreur
  def error
    @last_error ||= "[LaTexBook] Aucune erreur rencontrée"
  end

  # Méthode appelée en fin de construction si le fichier
  # PDF n'existe pas.
  # Elle récupère le log latex et retourne un message d'erreur
  def pdf_does_not_exist
    log LaTexBook::main_log_file.read
    return "Le fichier PDF est introuvable. Un problème est survenu au cours de la compilation LaTex (consulter le débug)."
  end

  # Méthode qui retourne le message de suivi
  def suivi
    @logs.join("\n")
  end

  # Méthode pour enregistrer un message de suivi
  def log mess
    @logs ||= Array::new
    @logs << mess
  end

  # Retourne les erreurs rencontrées (ou NIL s'il n'y en
  # a pas eu)
  def errors
    return nil if self.class::errors.nil?
    self.class::errors.join("\n")
  end

end
