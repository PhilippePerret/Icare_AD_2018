# encoding: UTF-8
=begin

=end
def schema_table_icetapes
  <<-MYSQL
CREATE TABLE icetapes
  (
    # ID
    # ---
    # Identifiant universel de l'ic-étape
    id INTEGER AUTO_INCREMENT,

    # ABS_ETAPE_ID
    # ------------
    # Identifiant de l'étape absolu
    # Attention, cet identifiant n'a plus rien à voir avec le numéro
    # de l'étape. Il est absolu par rapport à tous les modules et
    # permet une instanciation plus facile
    abs_etape_id INTEGER NOT NULL,

    #  USER_ID
    # ---------
    # Identifiant de l'user possédant cette étape
    user_id INTEGER NOT NULL,

    # ICMODULE_ID
    # -----------
    # Identifiant de l'ic-module
    icmodule_id INTEGER NOT NULL,

    #  NUMERO
    # -----------
    # Numéro de l'étape absolue, qui NE correspond PLUS à son ID dans la
    # table des données absolues des étapes.
    # Cette donnée pourrait être récupérée par l'étape absolue, mais
    # elle est placée ici pour ne pas avoir toujours à charger l'étape
    # absolue.
    numero INTEGER(4) NOT NULL,

    #  STARTED_AT
    # ------------
    # Date de démarrage de l'étape, qui correspond à la date de
    # création de cette donnée (il n'y a pas de created_at pour
    # cette table).
    started_at INTEGER(10) NOT NULL,

    # EXPECTED_END
    # ------------
    # Fin attendue, en fonction du nombre de jours définis pour l'étape
    # et des modifications d'échéance demandées par l'icarien
    expected_end INTEGER(10) NOT NULL,

    # EXPECTED_COMMENTS
    # -----------------
    # La date envisagée pour la remise des commentaires, en fonction
    # du module d'apprentissage. Cette valeur est nil quand l'icetape
    # est amorcée, elle ne sera précisée que lorsque l'icarien
    # remettra son travail
    expected_comments INTEGER(10),

    # OBSOLETE : COMMENTED_AT
    # -----------------------
    # Date à laquelle les commentaires ont été remis
    # OBSOLÈTE : MAINTENANT, CE SONT LES DOCUMENTS QUI CONTIENNENT
    # LES DATES DE COMMENTAIRE. ICI, SI ON EN A BESOIN, ILS PEUVENT
    # CORRESPONDRE À LA DATE DE FIN ENDED_AT

    #  ENDED_AT
    # ----------
    # Fin réelle de l'ic-étape, la vrai date à laquelle elle s'est
    # achevée
    ended_at INTEGER(10),

    # DOCUMENTS
    # -------------
    # Liste des identifiants de documents de cette étape
    # C'est une liste d'identifiants séparés par des espaces.
    # Les identifiants correspondent aux ID dans la table des
    # icdocuments.
    documents BLOB,

    #  STATUS
    # --------
    # État de l'étape (cf. le fichier state.rb)
    status INTEGER(1) DEFAULT 0,

    #  OPTIONS
    # ---------
    # Options. cf. le fichier :
    # ./objet/ic_etape/lib/required/instance/options.rb
    options VARCHAR(8),

    # TRAVAIL_PROPRE
    # --------------
    # Travail propre de l'étape, s'il est défini. Il ne l'est défini
    # qu'optionnellement, pour les modules coaching par exemple, ou pour
    # les étapes adaptées au suivi.
    travail_propre TEXT,


    # UPDATED_AT
    # ----------
    # Date de dernière modification de cette donnée.
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
