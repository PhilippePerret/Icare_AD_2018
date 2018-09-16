# encoding: UTF-8
class UserSpec

  PRENOMS_F = ["Salomé", "Marion", "Hélène", "Sandrine", "Dorothé", "Cloé", "Cloé", "Bernadette", "Jacqueline", "Laurence", "Yvonne", "Marguerite", "Yvette", "Bérangère", "Stéphanie", "Sylvette", "Liza", "Élizabeth", "Martine",
    "Solange", "Solène", "Valérie", "Sonia", "Manon", "Brigitte", "Christine", "Véronique", "Daniela", "Doris", "Vera", "Anne", "Annie"]

  PRENOMS_H = ["Élie", "Didier", "Pascal", "Varante", "Philippe", "Hubert", "Félix", "Salvator", "René", "Gilles", "Laurent", "Thierry", "Vincent", "John", "Stéphane", "Sylvain", "Bruno", "Bernard", "Martin", "Simon", "Serge", "Vernon", "Guillaume", "Yvan", "Hugues", "Daniel", "Armand", "Raymond", "Robert", "Roger", "Joan", "Lars", "Bertrand"]

  NOMBRE_PRENOMS_F = PRENOMS_F.count
  NOMBRE_PRENOMS_H = PRENOMS_H.count

  # Retourne un prénom au hasard
  def self.random_prenom sexe
    if sexe == 'F'
      PRENOMS_F[rand(NOMBRE_PRENOMS_F)]
    else
      PRENOMS_H[rand(NOMBRE_PRENOMS_H)]
    end
  end

end
