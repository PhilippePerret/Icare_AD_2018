# encoding: UTF-8
=begin
Schéma de la table contenant les tickets
=end
def schema_table_actualites
  <<-MYSQL
CREATE TABLE actualites
  (
    id          INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Pour information seulement, l'identifiant de l'user
    # concerné par l'actualité.
    user_id     INTEGER,

    # MESSAGE
    # -------
    # Le texte du message de l'actualité, entièrement mis en forme
    message     TEXT,

    #  STATUS
    # --------
    # Statut de l'actualité :
    # 0: ne doit ni être envoyée, ni être placée sur l'accueil
    # 1: Placée sur l'accueil mais pas encore envoyée par le mail
    #    quotidien
    # 2: Envoyée par le mail quotidien mais pas le mail hebdomadaire
    # 3: Envoyée par le mail quotidien et hebdomadaire (plus rien à faire)
    status INTEGER(1) DEFAULT 1,

    #  DATA
    # ------
    # Des données éventuellement pour l'actualité. Le mieux est
    # que ce soit un Hash jsonné.
    data        BLOB,

    created_at  INTEGER(10),
    updated_at  INTEGER(10),
    PRIMARY KEY (id)
  );
  MYSQL
end
