# encoding: UTF-8
=begin
Schéma de la table contenant les watchers
=end
def schema_table_watchers
  <<-MYSQL
CREATE TABLE watchers
  (
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Propriétaire du watcher, ou user visé
    #
    user_id     INTEGER,

    # OBJET
    # -----
    # Objet pour le watcher. Définit le dossier objet dans lequel
    # on cherchera le processus.
    objet       VARCHAR(255) NOT NULL,

    # OBJET_ID
    # --------
    # Identifiant de l'objet, par exemple l'identifiant
    # de l'étape du module.
    # Il peut très bien être nil, par exemple lorsque l'on doit
    # créer l'Icmodule d'un candidat
    objet_id    INTEGER,

    # PROCESSUS
    # ---------
    # Route du processus, en fonction de l'objet. Se trouve
    # défini dans ./_objet/<objet>/lib/processus/
    processus   VARCHAR(255) NOT NULL,

    triggered   INTEGER(10),
    data        BLOB,
    created_at  INTEGER(10),
    updated_at  INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
