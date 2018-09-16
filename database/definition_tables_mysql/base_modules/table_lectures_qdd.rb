# encoding: UTF-8
=begin
  Table permettant de consigner les lectures des documents du QDD

  NOTES
    * Cette table doit remplacer l'user des données cote, readers et
      autres de la table icdocuments

=end
def schema_table_lectures_qdd
  <<-MYSQL
CREATE TABLE lectures_qdd
  (
    # ID
    # ---
    # Identifiant universel de l'enregistrement
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # ID de l'user qui a procédé à cette lecture
    user_id INTEGER NOT NULL,

    #  ICDOCUMENT_ID
    # ---------------
    # ID du (double) document visé par cette lecture
    icdocument_id INTEGER NOT NULL,

    #  COTES
    # -------
    # Cote sur 5 attribuée au document original et au document
    # commentaires. C'est deux chiffres dont le premier concerne
    # le document original et le second le document commentaires
    # Si un document n'est pas coté, il est '-'
    cotes CHAR(2) DEFAULT '--',

    #  COMMENTS
    # ----------
    # Un commentaire éventuel du lecteur sur le document, par exemple
    # les points qui peuvent être intéressants
    comments TEXT,

    # CREATED_AT
    # ----------
    # Date de création, qui correspond à la date de téléchargement du
    # ou des documents
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Date de dernière modification de cette donnée.
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
