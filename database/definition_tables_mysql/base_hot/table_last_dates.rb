# encoding: UTF-8
=begin

Définition du schéma de la table qui conserve les dates de
dernière action. Par exemple le timestamp du dernier check des messages
forum par le cron-job
=end
def schema_table_last_dates
  <<-MYSQL
CREATE TABLE last_dates
  (
    id INTEGER AUTO_INCREMENT,
    cle VARCHAR(255) NOT NULL,
    time INTEGER(10) NOT NULL,
    PRIMARY KEY (id)
  );
  MYSQL
end
