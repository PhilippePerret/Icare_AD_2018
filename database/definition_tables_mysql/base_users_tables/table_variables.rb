# encoding: UTF-8
=begin
Pour consigner des valeurs propre à l'user, dans sa table
personnelle.

Pour enregistrer une valeur dans cette table on utilise
l'extension Unan :

  User::set_var <name>, <valeur>

<valeur> doit être un numbre fixnum, un string ou une valeur
booléenne.

=end
def schema_table_variables(user_id)
  # debug "-> schema_table_variables(#{user_id}) (création table 'variables_#{user_id}')"
  <<-MYSQL
CREATE TABLE variables_#{user_id}
  (
    # ID
    # ---
    # Toujours un ID, même s'il ne sert à rien ici
    id INTEGER AUTO_INCREMENT,

    # NAME
    # ----
    # Nom de la variable
    name VARCHAR(200) UNIQUE,

    # VALUE
    # -----
    # Valeur de la variable
    value BLOB,

    # TYPE
    # ----
    # Type de la variable
    # cf. VARIABLES_TYPES
    type INTEGER(1),

    #  UPDATED_AT
    # ------------
    # Pour l'utilisation de `set` qui actualise toujours
    # cette colonne
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
