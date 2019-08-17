# encoding: UTF-8
=begin

Class SiteHtml::Paiement::Command
---------------------------------
Gestion d'une commande/requête Paypal

=end
class SiteHtml
class Paiement
  class Command
    # ---------------------------------------------------------------------
    #   Classe
    # ---------------------------------------------------------------------
    class << self
      def url_paypal_nvp
        if sandbox?
          "https://api-3t.sandbox.paypal.com/nvp"
        else
          "https://api-3t.paypal.com/nvp"
        end
      end

      def sandbox?
        if @is_sandbox === nil
           @is_sandbox = SiteHtml::Paiement.sandbox?
        end
        @is_sandbox
      end
    end # << self

    # ---------------------------------------------------------------------
    #   Instances
    # ---------------------------------------------------------------------
    # {SiteHtml::Paiement} Instance du paiement
    attr_reader :paiement
    # {String} Description littéraire du paiement
    attr_reader :description
    # {Array} Les données envoyées, liste de paire name=value
    attr_reader :querystring

    # {Hash} Réponse retournée après l'exécution de la
    # requête
    attr_reader :response

    # +paiement+ {SiteHtml::Paiement} Instance du paiement
    # +description+ C'est juste la description littérale
    # du paiement. Pour information seulement
    def initialize paiement, description = nil
      @paiement     = paiement
      @description  = description
      @querystring  = Array.new
      add_authentification
    end

    # Exécution de la commande/requête
    def exec
      # debug "\n\n--- Requête exécuté : #{request}"
      @response = reponse_to_hash `#{request}`
      # debug "--- Retour de Paypal (transformé en Hash)"
      # debug response.pretty_inspect
      # debug "\n\n"
      # Si la valeur :amt existe, on la retransmet au paiement,
      # car elle sera peut-être plus juste que celle fourni
      # à make_transaction qui est toujours la même lorsque l'on
      # revient de paypal
      # paiement.montant = response[:amt].to_f if response.has_key?(:amt)
    end

    # ---------------------------------------------------------------------
    #   Données héritées de la réponse Paypal
    # ---------------------------------------------------------------------

    def token
      @token ||= response[:token]
    end
    def timestamp
      @timestamp ||= response[:timestamp]
    end
    def correlationid
      @correlationid ||= response[:correlationid]
    end
    def version
      @version ||= response[:version]
    end
    def build
      @build ||= response[:build]
    end

    # ---------------------------------------------------------------------

    def reponse_to_hash rep
      CGI.parse(rep).inject({}) do |res, (k, v)|
        res.merge!(k.downcase.to_sym => v.first)
      end
    end

    def failure?
      @is_failure ||= response[:ack] == "Failure"
    end
    def error
      @error ||= begin
        unless failure?
          "Aucune erreur n'est survenue"
        else
          err_code  = response[:l_errorcode0]
          err_short = response[:l_shortmessage0]
          err_long  = response[:l_longmessage0]
          "###&nbsp;#{err_long.gsub(/ /,'&nbsp;')}&nbsp;### [##{err_code}::#{err_short}]"
        end
      end
    end
    def success?
      @is_success ||= response[:ack] == 'Success'
    end

    # La requête qui sera exécutée
    def request
      @request ||= begin
        "curl -s #{mark_secure}#{url_paypal_nvp} -d \"#{querystring.join('&')}\""
      end
    end
    # La marque pour définir si la transaction doit être sécurisée,
    # en fonction du fait que c'est un test ou non
    def mark_secure
      @mark_secure ||= (sandbox? ? '--insecure ' : '')
    end

    # Raccourcis de classe
    def sandbox?; self.class::sandbox? end
    # URL du NVP de Paypal
    def url_paypal_nvp; @url_paypal_nvp ||= self.class::url_paypal_nvp end

    # Ajout systématique des paramètres d'authentification
    # Note : Fait à l'instanciation
    def add_authentification
      add paiement.params_authentify
    end
    # Pour ajouter des valeurs au querystring
    def << hdata
      hdata.each{ |name,value| @querystring << "#{name}=#{value}" }
    end
    alias :add :<<


  end # /Command


end # /Paiement
end # /SiteHtml
