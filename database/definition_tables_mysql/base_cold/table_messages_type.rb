# encoding: UTF-8
# encoding: UTF-8
=begin

Messages type pour mailing liste aux abonnés, inscrits,
administrateurs, analystes, etc. du site.

=end
def schema_table_messages_type
  <<-MYSQL
CREATE TABLE messages_type
  (
    #  ID
    # ----
    id INTEGER AUTO_INCREMENT,

    #  TITRE
    # -------
    # Ce n'est pas le sujet du message, c'est le titre qu'aura
    # le message dans le menu pour choisir un message type à
    # envoyer
    titre VARCHAR(255),

    #  SUBJECT
    # ---------
    # Le sujet du mail qui sera envoyé. S'il n'est pas
    # fourni, ce sera le sujet indiqué qui sera pris en compte
    # Noter que même s'il est fourni, si un sujet est indiqué dans
    # le formulaire, il aura la préférence.
    subject VARCHAR(255),

    #  MESSAGE
    # ---------
    # Le message proprement dit.
    message TEXT NOT NULL,

    #  FORMAT
    # --------
    # Le format du message, parmi :
    #   html, erb, md
    format ENUM('html', 'erb', 'md'),

    # OPTIONS
    # -------
    # Permettent de mieux préciser le message type ou prévoir
    # des comportements spéciaux.
    # Non utilisé pour le moment.
    options VARCHAR(32),

    #  LAST_SENT
    # -----------
    # Juste pour information, la dernière fois que le message
    # type a été envoyé.
    last_sent INTEGER(10),

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,

    # CREATED_AT
    # ----------
    # Date de création du message type
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
