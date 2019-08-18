# encoding: UTF-8
class Admin
class Paiements

  attr_reader :data

  def from_date
    @from_date ||= data[:from_date].nil_if_empty || get_date_first_paiement
  end
  def from_date_str
    @from_date_str ||= date_str_for(from_time)
  end
  def from_time
    @from_time ||= date_to_time(from_date)
  end
  def to_date
    @to_date ||= data[:to_date].nil_if_empty || Time.now.strftime('%d/%m/%Y')
  end
  def to_date_str
    @to_date_str ||= date_str_for(to_time)
  end
  def to_time
    @to_time ||= date_to_time(to_date)
  end

  # Liste des users ayant payé dans la zone de temps
  # spécifiée.
  def payeurs
    @payeurs ||= Hash.new
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Prend un temps (nombre de secondes) et retourne le
  # format 'JJ MM AAAA'
  def date_str_for d
    Time.at(d).strftime('%d %m %Y')
  end

  def get_date_first_paiement
    hdata = User.table_paiements.select(order: 'created_at ASC', limit: 1).first
    debug "#{hdata}"
    Time.at(hdata[:created_at]).strftime('%d/%m/%Y')
  end
  def date_to_time date
    jour, mois, annee = date.split('/').collect{|i|i.to_i}
    Time.new(annee, mois, jour).to_i
  end

  # Retourne le nombre de mois entre la première date
  # et la dernière
  def nombre_mois
    @nombre_mois ||= begin
      trente_jours_et_demi = 30.5 * 3600 * 24
      duree_couverte = to_time - from_time
      debug "duree_couverte : #{duree_couverte} (#{duree_couverte / 3600*24} jours)"
      t = (duree_couverte / trente_jours_et_demi).to_i
      debug "Nombre de mois brut : #{t}"
      # On doit ajouter un mois tous les quinze ans
      quinze_ans = 15 * 365 * 3600 * 24
      debug "Durée couverte : #{duree_couverte}"
      debug "Quinze ans     : #{quinze_ans}"
      debug "Nombre de mois ajoutés par quinze ans : #{duree_couverte / quinze_ans}"
      t += duree_couverte / quinze_ans
      t
    end
  end

end #/Paiements
end #/Admin
