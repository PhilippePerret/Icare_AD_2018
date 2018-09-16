# encoding: UTF-8

=begin

  Class MailMatcher
  -----------------
  Pour tester les mails

  * Pour obtenir le mail checké (si un seul):

    MailMatcher::mail_found
    # => Un hash avec les données du mail

  * Pour obtenir les mails checkés (si plusieurs)

    MailMatcher::mails_found
    # => Array de hash des données des mails

=end
class MailMatcher
  class << self

    # Les mails trouvés, qui correspondent à la recherche
    # C'est un Array d'instances MailMatcher
    attr_reader :mails_found
    # Les mails qui ne remplissaient pas les conditions de
    # la recherche.
    attr_reader :bad_mails

    # Tous les mails contenus dans le dossier temporaire
    # des mails envoyés.
    # Rappel : ils sont tous au format Marshal
    #
    # Array de Hash de données
    #
    # Chaque donnée contient :
    #   :subject      Le sujet complet du message
    #   :message      Le message
    #   :created_at   La date d'envoi
    #   :to           Le mail du destinataire
    #   :from         Le mail de l'expéditeur
    #
    def all_mails
      Dir["#{folder_mails_temp}/*.msh"].collect do |path|
        File.open(path, 'r'){ |f| Marshal.load(f) }
      end
    end

    # Retourne le nombre de mail
    def nombre_mails
      all_mails.count
    end

    def add_message mess
      @message_to_add ||= ""
      @message_to_add << "#{mess} "
    end
    def message_added
      @message_to_add || ""
    end
    def flush_message
      @message_to_add = nil
    end


    # Dossier contenant les données des mails qui
    # sont envoyés
    #
    def folder_mails_temp
      @folder_mails_temp ||= begin
        d = site.folder_tmp + 'mails'
        d.build unless d.exist?
        d
      end
    end

  end # << self
end #/MailMatcher
