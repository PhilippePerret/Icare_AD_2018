# encoding: UTF-8

# Schéma de la table 'connexions' de la base :hot
# Cette table permet de mémoriser les dates de dernières connexions
# des users
def schema_table_connexions
  <<-MYSQL
CREATE TABLE connexions
  (
    # ID
    # --
    #  Ici, ID est l'identifiant de l'user.
    id INTEGER NOT NULL,

    # TIME
    # ----
    # Le timestamp de la connexion
    time INTEGER(10) NOT NULL,

    # ROUTE
    # -----
    # La route empruntée pour cette connexion.
    route VARCHAR(255) NOT NULL
  );
  MYSQL
end
