# encoding: UTF-8
=begin

Module pour traiter le fait que l'user courant est un
moteur de recherche

=end

class User

  # Retourne true si l'user courant est un moteur
  # de recherche connu.
  def moteur_recherche?
    if @is_moteur_recherche === nil
      @is_moteur_recherche = cherche_if_moteur_recherche
    end
    @is_moteur_recherche
  end
  alias :seach_engine? :moteur_recherche?

  # Cherche si le visiteur peut être un moteur de
  # recherche et définit son pseudo et son ID en
  # fonction du résultat.
  # RETURN True si un moteur de recherche a été
  # trouvé.
  def cherche_if_moteur_recherche
    return false
  end

end
