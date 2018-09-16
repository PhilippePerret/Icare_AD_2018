# encoding: UTF-8
def schema_table_taches
  <<-MYSQL
CREATE TABLE taches
  (
    # ID
    # --
    # Identifiant de la tache
    id INTEGER AUTO_INCREMENT,

    # ADMIN_ID
    # --------
    # ID de l'administrateur (user) responsable de la
    # tache.
    admin_id INTEGER NOT NULL,

    # TACHE
    # -----
    # La tâche proprement dite
    tache TEXT,

    # DESCRIPTION
    # -----------
    # Le texte de la tâche
    description TEXT,

    # ECHEANCE
    # ---------
    # Timestamp de l'échéance de la tache
    # Elle peut être nil pour une tâche sans échéance particulière
    echeance INTEGER(10),

    #  FILE
    # ------
    # Fichier ou route associé à la tâche
    file VARCHAR(255),

    # STATE
    # -----
    # État (status) de la tâche.
    state INTEGER(1) DEFAULT 0,

    # UPDATED_AT
    # ----------
    # Date de dernière modification.
    updated_at INTEGER(10),

    # CREATED_AT
    # ----------
    # Date de création de la tâche
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  )
  MYSQL
end
