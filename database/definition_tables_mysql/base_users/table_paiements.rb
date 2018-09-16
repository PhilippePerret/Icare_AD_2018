# encoding: UTF-8
=begin

  Définition de la table `users` dans la table boite-a-outils_hot
  de la boite à outils de l'auteur

=end
def schema_table_paiements
  @schema_table_users ||= <<-MYSQL
CREATE TABLE paiements
  (
    #  ID
    # ----
    # Identifiant absolu et universel de l'user
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Identifiant de l'user ayant effectué le paiement
    user_id INTEGER,

    #  ICMODULE_ID
    # -------------
    # Objet du paiement
    icmodule_id INTEGER NOT NULL,

    #  OBJET
    # -------
    # L'objet du paiement, de façon humaine
    objet VARCHAR(255),

    # MONTANT
    # ---------
    # Montant en euros de la facture
    montant INTEGER(4),

    # FACTURE
    # -------
    # Facture
    facture VARCHAR(40),

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    # UPDATED_AT
    # ----------
    # Le paiement peut parfois être modifié, on ne sait jamais, donc
    # permettra de savoir s'il faut l'actualiser online/offline
    updated_at INTEGER(10),

    PRIMARY KEY (id)
  );
  MYSQL
end
