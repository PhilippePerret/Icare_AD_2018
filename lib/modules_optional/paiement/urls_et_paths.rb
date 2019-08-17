# encoding: UTF-8
=begin

Méthodes-propriétés pour les URL

=end
class SiteHtml
  class Paiement

    # Dossier de base du paiement. Par défaut, c'est le dossier './objet'
    # et il s'agit du paiement pour le site lui-même.
    def base_folder
      @base_folder ||= begin
        context.nil? ? site.folder_objet : (site.folder_objet + context)
      end
    end

    # URL de l'adresse de retour quand OK, c'est-à-dire quand
    # l'user a payé le module.
    # Noter que `base_url` ci-dessous est la base_url du paiement,
    # qui dépend de sandbox? ou pas sandbox?, pas le base_url du site
    # qui dépend de ONLINE ou OFFLINE.
    def url_retour_ok
      @url_retour_ok ||= begin
        url = "#{base_url}?pres=1"
        # url << "-#{context}" unless context.nil?
        url
      end
    end
    def url_retour_cancel
      @url_retour_cancel ||= begin
        url = "#{base_url}?pres=0"
        # url << "-#{context}" unless context.nil?
        url
      end
    end

    def base_url
      @base_url ||= ( sandbox? ? local_url : distant_url )
    end

    # Adresse locale pour le paiement (quand sandbox)
    def local_url
      @local_url ||= "#{site.local_url}/#{context || 'user'}/paiement"
    end
    # URL distant pour le paiement (non sandbox)
    def distant_url
      @distant_url ||= "#{site.distant_url}/#{context || 'user'}/paiement"
    end

    def url_paypal
      @url_paypal ||= "https://www.#{sandbox? ? 'sandbox.' : ''}paypal.com/cgi-bin/webscr"
    end

  end # /Paiement
end # /SiteHtml
