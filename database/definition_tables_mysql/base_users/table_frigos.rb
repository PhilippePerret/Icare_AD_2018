# encoding: UTF-8
=begin

  Définition de la table `frigos`

=end
def schema_table_frigos
  @schema_table_frigos ||= <<-MYSQL
CREATE TABLE frigos
  (
    #  ID
    # ----
    # Identifiant absolu et universel du frigo
    # Il correspond en fait à l'identifiant de l'user
    id INTEGER,

    # OPTIONS
    # -------
    # Les options du frigo.
    # 32 caractères pour spécifier tous les aspects du frigo
    #
    # Cf. le fichier ./_objet/bureau/lib/module/frigo/frigo/instance/options.rb
    options VARCHAR(32) DEFAULT '',

    #  LAST_MESSAGES
    # ---------------
    # Identifiants des derniers messages (10)
    last_messages VARCHAR(200) DEFAULT '',

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
