# encoding: UTF-8
=begin
  Schéma de la table des données absolues des modules d'apprentissage
=end
def schema_table_absmodules
  <<-MYSQL
CREATE TABLE absmodules
  (
    # ID
    # ---
    # Identifiant universel du module d'apprentissage
    # Note : c'est lui qui remplace l'ancienne utilisation de
    # module_id
    id INTEGER(2) NOT NULL,

    # MODULE_ID
    # ---------
    # Ancien identifiant absolu pour le module. Il est gardé seulement
    # pour le nommage des fichiers sur le Quai des docs (et le download
    # des commentaires une deuxième fois).
    # Le nouveau fonctionnement se fait avec les ID des modules.
    module_id VARCHAR(40) NOT NULL,

    #  NAME
    # ------
    # Nom humain du module
    # P.e. "Analyse de films"
    name VARCHAR(50) NOT NULL,

    #  TARIF
    # -------
    # Tarif du module, en euros
    tarif INTEGER(4) NOT NULL,

    # NOMBRE_JOURS
    # ------------
    # Nombre de jours
    # Note : la propriété type_suivi a été supprimée, il suffit de
    # voir si nombre_jours est nil pour savoir que le type est suivi
    nombre_jours INTEGER(3),

    #  HDUREE
    # --------
    # La durée humaine (exprimée de façon humaine)
    # P.e. "Deux mois" ou "90 jours"
    # Note : nil pour les modules de type suivi
    hduree VARCHAR(100),

    # SHORT_DESCRIPTION
    # -----------------
    # Description courte
    short_description TEXT NOT NULL,

    # LONG_DESCRIPTION
    # ----------------
    # Description complète du module
    long_description TEXT NOT NULL,

    # CREATED_AT
    # ----------
    created_at INTEGER(10) NOT NULL,

    # UPDATED_AT
    # ----------
    updated_at INTEGER(10) NOT NULL,


    PRIMARY KEY (id)
  );
  MYSQL
end
