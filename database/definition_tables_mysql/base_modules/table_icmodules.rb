# encoding: UTF-8
=begin
  Schéma de la table des Ic-modules, les modules propres aux icariens
=end
def schema_table_icmodules
  <<-MYSQL
CREATE TABLE icmodules
  (
    # ID
    # ---
    # Identifiant universel de l'ic-module
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Identifiant de l'user suivant le module
    user_id INTEGER NOT NULL,

    # ABS_MODULE_ID
    # -------------
    # Identifiant du module absolu, un nombre de 1 à 20 environ,
    # correspondant à l'enregistrement dans la table des modules
    # absolus.
    # Note : le nouveau fonctionnement ne se fait plus avec des
    # 'suivi_lent' etc.
    abs_module_id INTEGER(2) NOT NULL,

    # PROJECT_NAME
    # ------------
    # Nom du projet défini par l'user
    project_name VARCHAR(250),

    # NEXT_PAIEMENT
    # -------------
    # Date du prochain paiement
    next_paiement INTEGER(10),

    #  PAIEMENTS
    # -----------
    # Liste des Identifiants des paiements dans la table des paiements
    # Liste d'id paiements séparés par des espaces
    paiements BLOB,

    #  STARTED_AT
    # ------------
    # Date de démarrage du module, qui correspond à la date de
    # création de cette donnée (il n'y a pas de created_at pour
    # cette table).
    started_at INTEGER(10),

    #  ENDED_AT
    # ----------
    ended_at INTEGER(10),

    #  OPTIONS
    # ---------
    # Options
    # cf. ./_objet/ic_module/lib/required/instance/options.rb
    options VARCHAR(16),

    #  PAUSES
    # --------
    # Liste des pauses
    pauses BLOB,

    # ICETAPES
    # --------
    # Liste des identifiants d'ic-étapes du module. C'est maintenant
    # une simple liste d'id séparés par des espaces
    icetapes BLOB,

    #  ICETAPE_ID
    # ------------
    # IDentifiant de l'étape courante dans la table
    # modules.etapes
    icetape_id INTEGER,

    #  CREATED_AT
    # ------------
    created_at INTEGER(10),

    #  UPDATED_AT
    # ------------
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
