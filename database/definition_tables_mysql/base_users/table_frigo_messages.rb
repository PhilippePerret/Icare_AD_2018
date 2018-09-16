# encoding: UTF-8
=begin

  Définition de la table `frigo_messages` qui consigne toutes les
  messages des discussions sur les frigos.

=end
def schema_table_frigo_messages
  @schema_table_frigo_messages ||= <<-MYSQL
CREATE TABLE frigo_messages
  (
    #  ID
    # ----
    # Identifiant absolu et universel du message
    id INTEGER AUTO_INCREMENT,

    #  DISCUSSION_ID
    # ---------------
    # Identifiant de la discussion à laquelle appartient ce
    # message. Index.
    discussion_id INTEGER NOT NULL,

    #  AUTEUR_REF
    # ------------
    # Référence de l'auteur du message. C'est soit la lettre 'o' (pour 'owner')
    # soit la lettre 'i' (pour 'interlocuteur'). Donc, si c'est 'o',
    # c'est le propriétaire qui écrit le message, si c'est 'i', c'est
    # la personne qui vient sur le bureau de l'icarien.
    auteur_ref CHAR(1) NOT NULL,

    #  CONTENT
    # ---------
    # Contenu textuel du message
    content TEXT NOT NULL,

    # OPTIONS
    # -------
    # Les options du frigo.
    # 8 caractères pour spécifier tous les aspects de la discussion
    #
    # Cf. le fichier ./objet/bureau/lib/module/frigo/message/instance/options.rb
    options VARCHAR(8) DEFAULT '',

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id)
  );
  MYSQL
end
