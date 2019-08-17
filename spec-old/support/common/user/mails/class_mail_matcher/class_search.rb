# encoding: UTF-8
=begin

  Class MailMatcher
  -----------------
  Méthodes de recherche

=end
class MailMatcher
  class << self

    # Méthode appelée avant chaque recherche pour initialiser
    # les données.
    def reset_search
      @mails_found  = Array.new
      @bad_mails    = Array.new
      flush_message
    end

    # Méthode de class principale qui cherche les mails
    #
    # Elle les met dans mails_found qui sera testé (si un seul mail
    # cherché, sera vrai si = 0 et si plusieurs cherchés vrai si >
    # à 0)
    #
    def search_mails_with data_search
      reset_search

      # On répète dans tous les mails relevés
      all_mails.each_with_index do |hmail, imail|
        # puts "Test mail #{imail+1}"
        mail = new(hmail)
        # mail.verbose = true if imail == 1
        resultat = mail.match?(data_search.dup)
        # puts "Le résultat pour le mail #{imail} est #{resultat.inspect}"
        if resultat
          @mails_found << mail
        else
          @bad_mails << mail
        end
      end
    end

  end #/ << self
end #/MailMatcher
