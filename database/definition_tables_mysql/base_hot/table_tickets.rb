# encoding: UTF-8
=begin
Schéma de la table contenant les tickets
=end
def schema_table_tickets
  <<-MYSQL
CREATE TABLE tickets
  (
    id          VARCHAR(32)   NOT NULL,
    code        BLOB          NOT NULL,
    user_id     INTEGER,
    created_at  INTEGER(10),
    updated_at  INTEGER(10),
    PRIMARY KEY (id)
  );
  MYSQL
end
