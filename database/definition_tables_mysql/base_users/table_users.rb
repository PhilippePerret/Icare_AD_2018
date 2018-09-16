# encoding: UTF-8
=begin

  Définition de la table `users` dans la table boite-a-outils_hot
  de la boite à outils de l'auteur

=end
def schema_table_users
  @schema_table_users ||= <<-MYSQL
CREATE TABLE users
  (
    #  ID
    # ----
    # Identifiant absolu et universel de l'user
    id INTEGER AUTO_INCREMENT,

    # PSEUDO
    # ------
    pseudo VARCHAR(40) NOT NULL UNIQUE,

    # PATRONYME
    # ---------
    # Un patronyme doit toujours être fourni
    # Mais il n'est pas encore utilisé maintenant
    patronyme VARCHAR(255) UNIQUE,

    # MAIL
    # ----
    mail VARCHAR(255) NOT NULL UNIQUE,

    # CPASSWORD
    # ---------
    # Mot de passe crypté.
    cpassword VARCHAR(32) NOT NULL,

    # SALT
    # ----
    # Le sel qui permet de crypter le mot de passe
    salt VARCHAR(32) NOT NULL,

    # SESSION_ID
    # ----------
    # Le numéro de session courant, pour voir si l'utilisateur
    # est toujours dans la même session ou non (comptage de pages
    # par exemple)
    session_id VARCHAR(32),

    #  IP
    # ----
    # Dernière adresse IP de l'utilisateur
    ip VARCHAR(30),

    # OPTIONS
    # -------
    # Les options de l'user.
    # 32 caractères (ou plus) pour spécifier l'user
    # Cf. le fichier ./lib/deep/deeper/required/User/instance/options.rb
    # ATTENTION : LES OPTIONS PEUVENT ÊTRE DÉFINIES :
    #   - de 0 à 15 pour restsite dans User/instance/options.rb
    #   - de 16 à 31 pour l'application :
    #     - dans ./objet/user/lib/required/user/instance/options.rb
    #     - dans ./objet/site/config.rb (user_options)
    options VARCHAR(32) NOT NULL,

    # SEXE
    # ----
    # 'H' ou 'F' pour savoir si c'est un homme ou une femme
    sexe CHAR(1) NOT NULL,

    # NAISSANCE
    # ---------
    # Année de naissance sur 4 chiffres
    naissance INTEGER(4),

    #  ADRESSE
    # ---------
    # Adresse physique de l'user
    adresse TEXT,

    # TELEPHONE
    # ---------
    telephone VARCHAR(10),

    # ICMODULE_ID
    # -----------
    # Identifiant du module d'apprentissage courant
    # Nil si aucun module courant.
    icmodule_id INTEGER,

    # DATE_SORTIE
    # ------------
    # Date à laquelle l'icarien est "sorti" de l'atelier,
    # c'est-à-dire où il a terminé son module
    date_sortie INTEGER(10),

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
