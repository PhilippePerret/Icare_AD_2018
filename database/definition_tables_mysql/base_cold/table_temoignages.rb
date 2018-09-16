# encoding: UTF-8
#
# Définition du schéma de la table qui enregistre le travail du cron job
#
# Chaque ligne est pensée pour etre une opération (importante) du cron job
# Pour le moment, une action "importante" est un envoi de mail à un destinataire
# mais plus tard on pourra peut-être réduire le niveau de l'enregistrement pour
# que ne soit enregistrée que la liste des différentes destinataires ayant reçu
# un certain mail.
def schema_table_temoignages
  <<-MYSQL
CREATE TABLE temoignages
  (
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Identifiant de l'user — forcément inscrit — qui a laissé
    # le commentaire
    user_id INTEGER NOT NULL,

    #  USER_PSEUDO
    # --------------
    # Le pseudo, pour mémoire et afficher plus vite, et aussi
    # dans le cas où l'inscription serait détruite.
    user_pseudo VARCHAR(200) NOT NULL,

    #  ABS_MODULE_ID
    # ---------------
    # ID du module d'apprentissage suivi par l'icarien avant
    # ce témoignage
    abs_module_id INTEGER(2),

    #  CONTENT
    # ---------
    # Le témoignage lui-même
    #
    content TEXT NOT NULL,

    #  CONFIRMED
    # -----------
    # Mis à 1 quand le témoignage est confirmé
    confirmed INTEGER(1) DEFAULT 0,


    created_at  INTEGER(10)       NOT NULL,
    updated_at  INTEGER(10)       NOT NULL,


    PRIMARY KEY (id)
  );
  MYSQL
end
