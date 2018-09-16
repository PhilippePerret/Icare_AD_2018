# encoding: UTF-8
=begin
  Schéma de la table des données absolues des étapes de modules
=end
def schema_table_abs_travaux_type
  <<-MYSQL
CREATE TABLE abs_travaux_type
  (
    # ID
    # ---
    # Identifiant universel du travail-type. Fait fi du module ou
    # du numéro d'étape pour s'adapter à la configuration REST
    id INTEGER AUTO_INCREMENT,

    #  SHORT_NAME
    # ------------
    # Identifiant littéraire, p.e. "etude_conflits"
    # Note : pourra disparaitre à l'avenir ou sera gardé pour permettre
    # de savoir tout de suite de quel travail on parle dans les définitions
    # des étapes
    short_name VARCHAR(200) NOT NULL,

    #  RUBRIQUE
    # ----------
    # Ne pas confondre avec les modules d'apprentissage, c'est une rubrique
    # dramaturgique comme 'analyse', 'structure', 'fondamentales', etc.
    # Note : la "route" du travail type, dans la définition du travail de
    # l'étape est construit avec "rubrique/short_name" (peut-être ajoutera-
    # t-on l'ID)
    # Cf. la liste complète ICI TODO
    rubrique VARCHAR(100) NOT NULL,

    #  TITRE
    # -------
    # Titre de l'étape
    titre VARCHAR(250) NOT NULL,

    #  TRAVAIL
    # ---------
    # Le détail du travail à effectuer
    travail TEXT NOT NULL,

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
