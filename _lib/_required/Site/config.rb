# encoding: UTF-8
=begin
Méthodes qui gèrent la configuration du site
=end
class SiteHtml

  # ---------------------------------------------------------------------
  #   Propriétés configurables
  #  ---------------------------------------------------------------------

  # Nom du site (ou son titre) pour affichage
  # Note : le "title", affiché dans la page, sera calculé selon
  # ce nom, capitalisé
  attr_accessor :name

  # Désignation officielle du site, pour les factures et mails
  # officiels
  attr_accessor :official_designation

  # Le préfix, pour mettre devant la page courante dans le
  # title HTML
  attr_accessor :title_prefix

  # Le séparateur de nom dans la balise title ("|" par défaut)
  attr_accessor :title_separator

  # Nom du cookie qui va maintenir le numéro de session.
  # Par défaut, il est égal à 'SESSRESTSITEWTB'
  attr_accessor :cookie_session_name

  # Mail de l'administrateur du site.
  # Définir `site.mail = "adresse@chez.moi"` dans le fichier de
  # configuration
  attr_accessor :mail

  # À ajouter au sujet du mail
  attr_accessor :mail_before_subject
  # La signature de tous les mails (au format HTML)
  attr_accessor :mail_signature

  # Array contenant la liste des mails à éviter pour tous les
  # envois
  attr_accessor :mails_out

  # HOST local et distant qui permettront de déterminer les propriétés
  # méthodes `local_url` et `distant_url`
  # {String} Host Local (par exemple 'localhost/AlwaysData/Icare_AD')
  attr_accessor :local_host
  # {String} Host Distant (p.e. 'www.atelier-icare.net')
  attr_accessor :distant_host
  # Domaine url (donc avec http:// en amorce)
  # Sert notamment pour l'analyse du positionnement du site sur
  # google (ranking)
  attr_accessor :domain_url

  # Serveur SSH pour le site
  attr_accessor :serveur_ssh
  attr_accessor :ssh_server

  # Mots clés
  # Servent aussi bien à renseigner la balise META de la page
  # HTML qu'à produire le positionnement du site, par rapport à
  # ces mots clés, dans Google
  attr_accessor :keywords

  # Description du site, pour la balise META description
  attr_accessor :description

  # Prix de l'abonnement au site, s'il est unique
  attr_accessor :tarif

  # Préfixe de nom de toutes les bases de données
  attr_accessor :prefix_databases

  # Définition propre à l'application des bits des options de
  # l'user
  attr_accessor :user_options

  # Définition des redirections possibles après le login
  # Cf. fichier ._objet/user/lib/required/user/instance/redirections.rb
  attr_accessor :redirections_after_login

  # Éditeur par défaut, pour l'édition des fichiers
  attr_accessor :default_editor

  # Éditeur de fichier Markdown
  attr_accessor :markdown_application

  # Affichage des tâches pour un administrateur
  attr_accessor :display_taches_for_administrator

  # Cf. l'explication dans le fichier site/config.rb
  attr_accessor :display_taches_for_user

  # Cf. l'explication dans le fichier site/config.rb
  attr_accessor :display_widget_taches

  # Cf. l'explication dans le fichier site/config.rb
  attr_accessor :afficher_helper_filename_lecteur

  attr_accessor :alert_apres_login

  # {String} Path au bin rspec pour jouer les tests
  # RSpec
  attr_accessor :rspec_command

  # {String} Le compte facebook (if any)
  # Note : Sera ajouté à la signature du mail si défini, précédé
  # de http://www.facebook.com/
  attr_accessor :facebook

  # {String} Compte twitter (simple) if any
  # Note : Sera ajouté à la signature du mail si
  # défini, précédé de https://twitter.com/
  attr_accessor :twitter

  # --------------------------------------------------
  # Paramètres pour l'inscription (données de l'user)
  #
  # Demander l'année à l'inscription si true (@naissance)
  attr_accessor :signup_with_year
  # Mettre à true si l'année n'est pas optionnelle
  attr_accessor :signup_year_required
  # Demander l'adresse et le téléphone si true (@adresse et @telephone)
  attr_accessor :signup_with_coordonnates
  # Mettre à true si le téléphone n'est pas optionnel
  attr_accessor :signup_phone_required
  # Mettre à true si l'adresse n'est pas optionnelle
  attr_accessor :signup_address_required
  # Mettre à true si le patronyme est requis
  attr_accessor :signup_patronyme_required

  # Pour le captcha
  attr_accessor :captcha_question
  attr_accessor :captcha_value


  # Séparateur des unités avec les décimales, particulièrement
  # dans un tarif
  def separateur_decimal; @separateur_decimal ||= "," end
  def separateur_decimal= value
    @separateur_decimal = value
    ::Float::separateur_decimal= value
  end

  # Devise de la monnaie
  # def devise; self.devise || "€" end
  def devise; @devise ||= "€" end
  def devise= value
    @devise = value
    ::Float::devise= value
  end

  # ---------------------------------------------------------------------
  #   Méthode de chargement des configurations
  # ---------------------------------------------------------------------
  def require_config
    if config_file.exist?
      # config_file.require # si singleton
      eval(config_file.read)
    else
      raise "Le fichier de configuration est introuvable… (#{config_file})"
    end
  end
  def config_file
    @path_config_file ||= SuperFile.new('config/site.rb')
  end
end
