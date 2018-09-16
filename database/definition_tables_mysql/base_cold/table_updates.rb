# encoding: UTF-8
=begin
  Table pour les updates

=end
def schema_table_updates
  <<-MYSQL
CREATE TABLE updates
  (
    id INTEGER AUTO_INCREMENT,

    # MESSAGE
    # -------
    # Le message humain de l'actualisation
    message TEXT NOT NULL,

    #  ROUTE
    # -------
    # Si l'actualisation concerne une page en particulier,
    # on peut indiquer ici sa route.
    route VARCHAR(255),

    #  TYPE
    # ------
    # Type de l'actualisation, son sujet.
    # cf. TYPES dans ./objet/site/lib/module/updates/contantes.rb
    type VARCHAR(20),

    # ANNONCE
    # -------
    # Détermine s'il faut annoncer l'actualisation dans les
    # mails d'actualité
    # 0 : Pas d'annonce
    # 1 : Annonce d'une fonction pour les inscrits
    # 2 : Annonce d'une fonction poru les abonnés (mais même les
    #     inscrits la reçoivent)
    annonce INTEGER(1),

    #  OPTIONS
    # ---------
    # Pas encore utilisé
    options VARCHAR(32) DEFAULT '000000',

    updated_at INTEGER(10) NOT NULL,
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
