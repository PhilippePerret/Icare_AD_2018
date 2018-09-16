# encoding: UTF-8
#
# Définition du schéma de la table qui enregistre le travail du cron job
#
# Chaque ligne est pensée pour etre une opération (importante) du cron job
# Pour le moment, une action "importante" est un envoi de mail à un destinataire
# mais plus tard on pourra peut-être réduire le niveau de l'enregistrement pour
# que ne soit enregistrée que la liste des différentes destinataires ayant reçu
# un certain mail.
def schema_table_page_comments
  <<-MYSQL
CREATE TABLE page_comments
  (
    id INTEGER AUTO_INCREMENT,

    #  USER_ID
    # ---------
    # Identifiant de l'user — forcément inscrit — qui a laissé
    # le commentaire
    user_id INTEGER NOT NULL,

    #  PSEUDO
    # --------
    # Le pseudo, pour mémoire et afficher plus vite, et aussi
    # dans le cas où l'inscription serait détruite.
    pseudo VARCHAR(200) NOT NULL,

    #  ROUTE
    # -------
    # La route, donc la page du commentaire
    # Elle peut être avec contexte, donc :
    # objet/objet_id/method?in=contexte
    #
    route VARCHAR(255) NOT NULL,

    #  COMMENT
    # ---------
    # Le commentaire lui-même
    #
    comment TEXT NOT NULL,

    #  VOTES_UP
    # ----------
    # Nombre de plébiscite du message (vote UP)
    votes_up INTEGER(8) DEFAULT 0,

    #  VOTES_DOWN
    # ------------
    # Nombre de votes négatifs
    votes_down INTEGER(8) DEFAULT 0,

    #  OPTIONS
    # ---------
    # Les options, à commencer par le fait que le message
    # est validé ou non
    options VARCHAR(16) DEFAULT '00000000',


    created_at  INTEGER(10)       NOT NULL,
    updated_at  INTEGER(10)       NOT NULL,


    PRIMARY KEY (id)
  );
  MYSQL
end
