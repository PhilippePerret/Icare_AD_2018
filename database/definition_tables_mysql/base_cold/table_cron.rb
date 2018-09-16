# encoding: UTF-8
#
# Définition du schéma de la table qui enregistre le travail du cron job
#
# Chaque ligne est pensée pour etre une opération (importante) du cron job
# Pour le moment, une action "importante" est un envoi de mail à un destinataire
# mais plus tard on pourra peut-être réduire le niveau de l'enregistrement pour
# que ne soit enregistrée que la liste des différentes destinataires ayant reçu
# un certain mail.
def schema_table_cron
  <<-MYSQL
CREATE TABLE cron
  (
    id INTEGER AUTO_INCREMENT,

    # CODE
    # ------
    # Un code de 5 chiffres ou lettre pour désigner l'action
    # qui est entreprise
    # Peut-être que chaque chiffres/lettre peut représenter une
    # action particulière. Il faudrait mettre à plat les différentes
    # choses que fait le cron
    # Ça peut être aussi la réussite ou non d'une opération.
    code VARCHAR(5),

    # INTITULE
    # --------
    # Le titre du travail du cronjob
    intitule    VARCHAR(255) NOT NULL,

    # DESCRIPTION
    # -----------
    # Une description assez précise de la tâche, ou peut-être le
    # contenu d'un mail lorsque c'est un mail qui est envoyé, ce
    # genre de choses.
    description TEXT,

    #  DATA
    # ------
    # Pour enregistrer une donnée quelconque
    data BLOB,

    updated_at  INTEGER(10)       NOT NULL,
    created_at  INTEGER(10)       NOT NULL,


    PRIMARY KEY (id)
  );
  MYSQL
end
