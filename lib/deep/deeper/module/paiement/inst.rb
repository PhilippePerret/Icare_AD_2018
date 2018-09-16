# encoding: UTF-8
=begin

Module de paiement

=end

# Ce module n'est accessible que si on est l'administrateur ou
# un utilisateur identifié. Dans tous les autres cas, il n'y a
# aucune raison de passer par là.
# raise unless user.admin? || user.identified?

class SiteHtml
  class Paiement

    # ---------------------------------------------------------------------
    #   Instances SiteHtml::Paiement
    # ---------------------------------------------------------------------

    # Pour les vues
    def bind; binding() end

    def sandbox?
      @is_sandbox ||= self.class::sandbox?
    end

    ##
    # Appelée quand le paiement a été effectué par l'Icarien sur
    # le site PayPal. Mais ce paiement n'est pas encore confirmé.
    #
    # C'est le retour du site Paypal quand l'Icarien a payé. Il faut
    # confirmer le paiement sur Paypal, et enregistrer le paiement
    # dans les données de l'Icarien.
    #
    def valider_paiement
      # debug "-> valider_paiement"
      # Instancier une commande Paypal
      command = Command.new(self, "Validation du paiement effectué")

      # Paramètres de la transaction
      command << {
        method:         'DoExpressCheckoutPayment',
        token:          token,
        PayerID:        payer_id,
        currencycode:   details_paiement[:currencycode],
        amt:            details_paiement[:amt],
        PaymentAction:  "SALE"
      }
      # === Exécuter la requête ===
      command.exec

      # debug "Validation du paiement : #{command.success? ? 'OUI' : 'NON'}"

      # Test du résultat
      if command.success?

        # Enregistrement du paiement dans la base de données
        save_paiement

        # Envoi d'un mail à l'utilisateur pour lui confirmer
        # le paiement
        send_mail_to_user

        # Envoi d'un mail à l'administration pour informer
        # du paiement
        mail_administration_annonce_paiement

        # S'il y a une méthode de fin de processus, il faut
        # l'appeler. Dans le cas contraire, on s'arrête là.
        after_validation_paiement if self.respond_to?(:after_validation_paiement)

        return true
      else
        err =  "Une erreur s'est produite : #{command.response[:l_shortmessage0]} / #{command.response[:l_longmessage0]}"
        send_error_to_admin err
        debug err
        return error err
      end

    rescue Exception => e
      error "Une erreur s'est malheureusement produite."
      send_error_to_admin(e)
      debug e.message
      debug e.backtrace.join("\n")
      debug "\n"+ "="*80
      debug "Full command envoyée : #{command.request}"
      debug "# Réponse de l'opération : #{command.response.inspect}"
    end

    # ---------------------------------------------------------------------
    #
    #   MÉTHODES UTILITAIRES
    #
    # ---------------------------------------------------------------------

    ##
    # {Hash} Retourne le Hash des détails de l'opération de
    # paiement après les avoir demandés à Paypal
    def details_paiement
      # On ne donnera une réponse positive que si le retour est
      # successful.
      command = Command.new(self, "Récupération des détails de paiement")

      # Les paramètres de la transaction
      command << {
        method:         'GetExpressCheckoutDetails',
        token:          token,
        PayerID:        payer_id
      }

      # On soumet la requête et on retourne les détails de l'opération
      # sous forme de Hash
      # NOTE : Dans la forme original de la méthode sur l'atelier
      # Icare, c'était une commande "--insecure" qui était envoyée. Ici,
      # si on n'est pas dans le bac à sable, ce sera une requête normale
      # qui sera à surveiller.
      command.exec
      return command.response

    end

    # Paramètres d'authentification
    def params_authentify
      @params_authentify ||= begin
        account = PAYPAL[sandbox? ? :sandbox_account : :live_account]
        {
          'USER'      => CGI::escape( account[:username] ),
          'PWD'       => account[:password],
          'SIGNATURE' => account[:signature],
          'VERSION'   => "119"
        }
      end
    end

  end # /Paiement
end # /SiteHtml
