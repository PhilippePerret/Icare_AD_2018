# encoding: UTF-8
class AbsModule

  # True si c'est un module de type suivi
  def type_suivi?
    @is_type_suivi = nombre_jours.nil? if @is_type_suivi === nil
    @is_type_suivi
  end

  # TRUE si c'est un module à rythme intensif
  # Permet de déterminer la date de remise attendue des commentaires
  def intensif?; [8, 12].include?(id) end
  # Juste pour le calcul de jours avant le retour sur les documents
  def suivi_lent?; id == 7 end

  # Note : la méthode exist? existe par les méthodes MySQL
end #/AbsModule
