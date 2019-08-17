# encoding: UTF-8
=begin

Ce module définit la procédure qui doit être employée pour
récupérer des données qui ont été backupées avant la transformation
d'une table (ajout de colonne ou autre).

=end
raise_unless_admin


class SiteHtml
class Admin
class Console

  # Méthode de transformation des données suite à la transformation
  # d'une table (après un backup et un destroy de la table)
  #
  # L'argument +data+ de la procédure correspond aux data telles
  # qu'elles sont été backupées, donc au format de l'ancienne table.
  # C'est un Hash de paire clé=>valeur.
  # On traite ce hash pour l'adapter au nouveau schéma de la table,
  # par exemple en supprimant ou modifiant des colonnes, puis on le
  # renvoie (le `data` est obligatoire en fin de procédure).
  #
  # Retourner simplement NIL si aucune transformation ne doit être
  # faite sur les données consignées.
  def db_procedure_transformation_data
    return nil # si aucune transformation ne doit être opérée
    Proc::new do |data|


      data
    end
  end
end #/Console
end #/Admin
end #/SiteHtml
