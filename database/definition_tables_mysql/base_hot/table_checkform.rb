# encoding: UTF-8
=begin
  Schéma de la table contenant les checkform, pour le test de re-submition
  de formulaire par rechargement de la page
=end
def schema_table_checkform
  <<-MYSQL
CREATE TABLE checkform
  (
    id INTEGER AUTO_INCREMENT,

    #  FORM_ID
    # ---------
    # ID du formulaire (pour information)
    form_id VARCHAR(100) NOT NULL,

    # SESSION_ID
    # Identifiant de session
    session_id  VARCHAR(32) NOT NULL,

    #  CHECKSUM
    # ----------
    # Le nombre inscrit dans le formulaire. Il est composé à l'aide
    # du numéro de session et de l'id du formulaire.
    checksum VARCHAR(32) NOT NULL,

    #  STATUS
    # --------
    # Status du traitement :
    #   0: Le formuulaire n'a pas été soumis
    #   1: Le formulaire a été soumis
    status INTEGER(1) NOT NULL,

    updated_at  INTEGER(10) NOT NULL,
    created_at  INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
