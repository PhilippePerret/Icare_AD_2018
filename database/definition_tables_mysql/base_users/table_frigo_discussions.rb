# encoding: UTF-8
=begin

  Définition de la table `frigo_discussions` qui consigne toutes les
  discussions sur les frigos.

=end
def schema_table_frigo_discussions
  @schema_table_frigo_discussions ||= <<-MYSQL
CREATE TABLE frigo_discussions
  (
    #  ID
    # ----
    # Identifiant absolu et universel de la discussion
    id INTEGER AUTO_INCREMENT,

    #  OWNER_ID
    # ----------
    # Identifiant du propriétaire du fil de discussion
    owner_id INTEGER NOT NULL,

    #  USER_ID
    # ---------
    # Identifiant de l'interlocuteur si c'est un icarien. Sinon,
    # on retrouve l'interlocuteur par le mail
    user_id INTEGER,

    #  USER_MAIL
    # -----------
    # S'il n'est pas icarien, on enregistre l'interlocuteur par
    # son mail. S'il est nil c'est que user_id est défini.
    user_mail VARCHAR(250),

    #  USER_PSEUDO
    # -------------
    # Dans tous les cas, un pseudo pour désigner l'interlocuteur,
    # qu'il soit ou non icarien
    user_pseudo VARCHAR(20) NOT NULL,

    #  CPASSWORD
    # -----------
    # Pour le quidam, le mot de passe crypté
    cpassword VARCHAR(32),

    # OPTIONS
    # -------
    # Les options du frigo.
    # 16 caractères pour spécifier tous les aspects de la discussion
    #
    # Cf. le fichier ./objet/bureau/lib/module/frigo/discussion/instance/options.rb
    options VARCHAR(32) DEFAULT '',

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,

    # CREATED_AT
    # ----------
    # Date de création de la donnée
    created_at INTEGER(10) NOT NULL,

    PRIMARY KEY (id),

    # Indexes
    # -------
    INDEX owner_idx (owner_id),
    INDEX user_idx (user_id),
    INDEX mail_idx(user_mail)

  );
  MYSQL
end
