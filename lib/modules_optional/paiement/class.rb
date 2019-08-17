# encoding: UTF-8
class SiteHtml

  # Le paiement courant
  # @usage : site.paiement.<méthode>
  def paiement
    @paiement ||= Paiement.new
  end

  class Paiement
    class << self

      # Méthode principale pour savoir si on est en mode de test
      # ou en réel.
      def sandbox?
        true == OFFLINE
      end

      # Les données Paypal
      # ------------------
      # C'est un fichier qui doit se trouver dans un dossier
      # secret, sauf indication contraire.
      # Note : après avoir utilisé `data` une première fois,
      # on peut aussi utiliser la constante PAYPAL dans le
      # programme, qui contient toutes les données PayPal.
      def data
        @data ||= begin
          path_data_file.require
          PAYPAL
        end
      end
      def path_data_file
        @path_data_file ||= ( site.folder_data_secret + 'paypal.rb')
      end
    end # << self Paiement
  end # /Paiement
end # /SiteHtml

# Pour forcer le chargement des données
SiteHtml::Paiement.data
