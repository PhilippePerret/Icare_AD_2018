# encoding: UTF-8
=begin
  Schéma de la table des données absolues des étapes de modules
=end
def schema_table_absetapes
  <<-MYSQL
CREATE TABLE absetapes
  (
    # ID
    # ---
    # Identifiant universel de l'étape. Elle fait fi du module ou
    # du numéro d'étape pour s'adapter à la configuration REST
    id INTEGER AUTO_INCREMENT,

    #  MODULE_ID
    # -----------
    # Identifiant numérique auquel appartient l'étape
    module_id INTEGER(2) NOT NULL,

    #  NUMERO
    # --------
    # Numéro de l'étape, de 1 à 999
    numero INTEGER(3) NOT NULL,

    #  TITRE
    # -------
    # Titre de l'étape
    titre VARCHAR(250) NOT NULL,

    #  TRAVAIL
    # ---------
    # Le détail du travail à effectuer
    travail TEXT NOT NULL,

    #  TRAVAUX
    # ---------
    # Liste des travaux lorsque travail n'est pas défini
    # C'est une liste stringifiée avec JSON
    travaux BLOB,

    #  OBJECTIF
    # ----------
    # Explicitation de l'objectif de l'étape
    # Note : il peut être nil s'il doit être défini par les travaux
    # qu'il contient.
    objectif TEXT,

    #  METHODE
    # ---------
    # Des éléments de méthode pour exécuter l'étape
    methode TEXT,

    # DUREE
    # -----
    # Nombre de jours qui doivent être consacrés à l'étape, au
    # départ.
    duree INTEGER(2),

    #  DUREE_MAX
    # -----------
    # Le nombre de jours maximum qui peut être consacré à l'étape
    # de travail. Passé ce jour, un avertissement est envoyé à
    # l'administration
    duree_max INTEGER(2),

    #  LIENS
    # -------
    # Des liens utiles, par exemple vers la collection Narration
    # C'est une liste stringifiée avec JSON
    liens BLOB,

    # CREATED_AT
    # ----------
    created_at INTEGER(10) NOT NULL,

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,


    PRIMARY KEY (id)
  );
  MYSQL
end
