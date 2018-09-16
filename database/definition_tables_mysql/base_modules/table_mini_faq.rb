# encoding: UTF-8
=begin

=end
def schema_table_mini_faq
  <<-MYSQL
CREATE TABLE mini_faq
  (
    # ID
    # ---
    # Identifiant universel de la question/réponse
    id INTEGER AUTO_INCREMENT,

    # ABS_MODULE_ID
    # ------------
    # Identifiant de l'étape absolu
    # Attention, cet identifiant n'a plus rien à voir avec le numéro
    # de l'étape. Il est absolu par rapport à tous les modules et
    # permet une instanciation plus facile
    abs_module_id INTEGER NOT NULL,

    #  ABS_ETAPE_ID
    # --------------
    # Identifiant absolu de l'étape absolue à laquelle est attachée
    # cette question/réponse.
    abs_etape_id INTEGER NOT NULL,

    # NUMERO
    # --------
    # Numéro de l'étape, pour raccourci
    numero INTEGER(4) NOT NULL,

    # USER_ID
    # --------
    # Identifiant de l'user qui a posé la question
    # Il peut arriver qu'il soit nil, dans l'ancienne version, et
    # il est alors remplacé par Benoit #2
    user_id INTEGER NOT NULL,

    # USER_PSEUDO
    # ------------
    # Le pseudo de l'auteur de la question, pour gagner du
    # temps dans la construction ou l'utilisation de la question
    user_pseudo VARCHAR(40),

    # CONTENT
    # -------
    # Le contenu mis en forme, pour ne pas avoir à le faire
    content TEXT,

    # QUESTION
    # --------
    # La date envisagée pour la remise des commentaires, en fonction
    # du module d'apprentissage. Cette valeur est nil quand l'icetape
    # est amorcée, elle ne sera précisée que lorsque l'icarien
    # remettra son travail
    question TEXT NOT NULL,

    # REPONSE
    # -------
    # La réponse à la question
    reponse TEXT,

    #  OPTIONS
    # ---------
    # Options à définir, inutilisés encore pour le moment.
    options VARCHAR(8),


    # CREATED_AT
    # ----------
    created_at INTEGER(10),

    # UPDATED_AT
    # ----------
    # Date de dernière modification de cette donnée.
    updated_at INTEGER(10),


    PRIMARY KEY (id)
  );
  MYSQL
end
