# encoding: UTF-8

# Schéma de la table 'connexions' de la base :hot
# Cette table permet de mémoriser les dates de dernières connexions
# des users
def schema_table_connexions_per_ip
  <<-MYSQL
CREATE TABLE connexions_per_ip
  (
    # IP
    # --
    #  IP de l'utilisateur
    ip VARCHAR(30) NOT NULL,

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
