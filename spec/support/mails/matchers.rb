# encoding: UTF-8
=begin

=end
module TMailMatchers
  module Matchers

    class HasBeenSent
      class << self
        attr_accessor :last_mail_found
      end

      attr_reader :recherche, :mail_found

      attr_reader :nombre_founds, :nombre_expected

      def matches? search_data
        @recherche = search_data
        @nombre_expected = search_data.delete(:count) || 1
        founds = TMail.search(search_data)
        @nombre_founds = founds.count
        @found = founds.first
        self.class.last_mail_found = @found
        @nombre_founds == @nombre_expected
      end
      def description
        "Un mail correspondant à #{ref_recherche} a été envoyé."
      end
      def failure_message
        if nombre_founds > 0 && nombre_founds != nombre_expected
          "Le nombre de mails envoyés (#{nombre_founds}) qui correspondent à la recherche #{ref_recherche} est différent du nombre attendu (#{nombre_expected}). Merci d'affiner la recherche où d'indiquer combien de mails doivent être trouvés."
        else
          # C'est une erreur
          "Aucun mail n'a pas été envoyé correspondant à la recherche #{ref_recherche}."
        end
      end
      def failure_message_when_negated
        "Le mail n'aurait pas dû être envoyé."
      end

      def ref_recherche
        @ref_recherche ||= recherche.inspect
      end
    end

    def have_been_sent
      HasBeenSent.new
    end

  end #/Matchers
end #/TMailMatchers
