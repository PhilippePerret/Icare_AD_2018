# encoding: UTF-8
=begin

=end
def schema_table_icdocuments
  <<-MYSQL
CREATE TABLE icdocuments
  (
    # ID
    # ---
    # Identifiant universel de l'ic-document
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Identifiant de l'user possédant ce document
    user_id INTEGER NOT NULL,

    # ABS_MODULE_ID
    # -------------
    # Identifiant du module auquel est associé le document
    abs_module_id INTEGER(2) NOT NULL,

    # ABS_ETAPE_ID
    # -------------
    # Identifiant absolu de l'étape absolue auquel est associé
    # le document, c'est-à-dire qu'il a été exécuté lors de
    # cette étape de travail
    abs_etape_id INTEGER NOT NULL,

    # ICMODULE_ID
    # -----------
    # Identifiant de l'ic-module du document, si le document
    # est associé à un module
    icmodule_id INTEGER,

    # ICETAPE_ID
    # ---------
    # Identifiant de l'ic-étape du document si le document
    # est associé à une étape
    icetape_id INTEGER,

    #  DOC_AFFIXE
    # ------------
    # Affiche du document, c'est-à-dire le nom sans extension
    # Note : permettra aussi de déterminer le nom du document
    # de commentaire, en ajoutant '_comsPhil' à cette affixe
    doc_affixe VARCHAR(70) NOT NULL,

    #  ORIGINAL_NAME
    # ---------------
    # Le nom original fourni par l'icarien
    original_name VARCHAR(70) NOT NULL,

    # TIME_ORIGINAL
    # -------------
    # Le temps de remise du document original (normalemnent correspond
    # au temps de création de cette donnée)
    time_original INTEGER(10),

    # EXPECTED_COMMENTS
    # -----------------
    # La date approximative de remise des commentaires
    # pour ce document
    expected_comments INTEGER(10),

    # TIME_COMMENTS
    # -------------
    # Le temps de remise du document de commentaire.
    time_comments INTEGER(10),

    #  OPTIONS
    # ---------
    # Options pour définir
    # Les bits 0 à 7 (8 premiers) correspondent à l'original
    # Les bits 8 à 15 correspondent au document commentaires
    # Bit 0/8   Le document existe (original ou commentaire)
    # Bit 1/9   L'accès aux document 1: partagé, 0: non défini, 2: non partagé
    # Bit 2/10  Le document a été téléchargé par l'user ou l'admin
    # Bit 3/11  Upload sur QDD (1: oui, 0: non)
    # Bit 4/12  La définition du partage a été donné
    # Bit 5/13  Si 1, le document est arrivé en bout de cycle de vie
    options VARCHAR(16),

    # COTE_ORIGINAL
    # -------------
    # La cote attribuée pour l'original. C'est un calcul qui est
    # fait en fonction de toutes les lectures (cf. la table lectures)
    cote_original DECIMAL(2,1),

    # COTE_COMMENTS
    # -------------
    # La cote attribuée pour le commentaire. C'est un calcul qui est
    # fait en fonction de toutes les lectures (cf. la table lectures)
    cote_comments DECIMAL(2,1),

    # CREATED_AT
    # ----------
    # Date de création de la donnée présente
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Date de dernière modification de cette donnée.
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
