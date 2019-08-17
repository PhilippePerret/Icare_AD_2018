# encoding: UTF-8
=begin

  Module principal pour procéder au paiement.

  NOTES


    * param(:watcher_id).to_i contient l'identifiant du watcher
      du paiemnet qui a conduit jusqu'ici. Pour pouvoir le runner
      lorsque tout s'est bien passé.

    * Un paiement n'est pas forcément associé à un module, on doit
      pouvoir le faire sans module (don)


=end
# Ce module n'est accessible que si on est l'administrateur ou
# un utilisateur identifié. Dans tous les autres cas, il n'y a
# aucune raison de passer par là.
raise_unless user.admin? || user.identified?

require './data/secret/paypal'

class User

  # Retourne True si l'user a un paiement à effectuer
  #
  # On fait une recherche en règle, en vérifiant vraiment dans les
  # modules de l'user. Si on trouve un module non payé qui n'est pas
  # le module courant, on génère une erreur fatale.
  #
  def has_paiement?
    user_hmodules = site.dbm_table(:modules, 'icmodules').select(where:{user_id: self.id})
    user_hmodules.each do |hmodule|
      hmodule[:next_paiement].nil? || begin
        if self.icmodule.id != hmodule[:id]
          raise('Un problème se pose : le module à payer n’est pas le module courant…')
        end
        return true
      end
    end
  end
end

class IcPaiement
class << self

  # = main =
  #
  # Méthode principale appelée quand on arrive sur la page de paiement
  # et que l'user a son module courant à payer.
  #
  # RETURN Le code HTML du formulaire pour procéder au paiement
  def init_paiement_et_affiche_formulaire
    IcPaiement.require_module 'init_and_form'
    IcPaiement.new.init
  end

  # = main =
  #
  # Méthode appelée lorsque l'on revient du paiement et que tout
  # s'est bien passé (en tout cas, que l'user n'a pas annulé son paiement)
  def do_paiement_ok
    IcPaiement.require_module 'on_paiement_ok'
    IcPaiement.new.on_ok
  end

  def do_paiement_cancel
    IcPaiement.require_module 'on_cancel_paiement'
    IcPaiement.new.on_cancel
  end

  def aucun_paiement
    'Vous n’avez aucun paiement à effectuer pour l’atelier Icare.'.in_p(class: 'big air')
  end

end #/<<self

  # ---------------------------------------------------------------------
  #   Données générales du paiements
  # ---------------------------------------------------------------------

  # {String} Objet du paiement (en général, pour un module)
  attr_reader :objet
  # {String} L'action de formulaire
  attr_reader :form_action
  # {Fixnum} ID de la rangée du paiement dans la table des
  # paiements
  # Note : cette valeur n'est définie que si le paiement a été
  # effectué avec succès. C'est l'ID de la rangée dans la base
  attr_reader :paiement_id

  # Le token de paiement. La première fois, il est défini explicitement
  # par la méthode #init. Ensuite il est mis dans le formulaire et
  # retourné par les paramètres.
  def token
    @token ||= param(:token)
  end
  # L'ID de paiement, n'est défini que lorsqu'on revient de l'instanciation
  # du paiement.
  def payer_id
    @payer_id ||= param(:PayerID)
  end

  # ---------------------------------------------------------------------
  #   Raccourcis
  # ---------------------------------------------------------------------

  # Les méthodes icmodule et abs_module surclassent les méthoes
  # d'origine qui travaillent normalement avec l'enregistrement du
  # paiement. Ici, on doit prendre le module courant de l'icarien
  def icmodule
    @icmodule ||= user.icmodule
  end

  def abs_module
    @abs_module ||= icmodule.abs_module
  end

  def sandbox?
    @for_sandbox ||= self.class.sandbox?
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  # Méthode décomposant la réponse de CURL en la transformant en
  # un Hash avec des clés symboliques.
  #
  def reponse_paypal_to_hash reponse
    CGI.parse(reponse).inject({}) do |res, (k, v)|
      res.merge!(k.downcase.to_sym => v.first)
    end
  end

  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles de classe
  # ---------------------------------------------------------------------
  class << self

    # La valeur retournée est true si on est en mode test
    def sandbox?
      if @operation_in_the_sandbox === nil
        @operation_in_the_sandbox = app.test?
      end
      @operation_in_the_sandbox
    end

    def url_paypal_nvp
      if sandbox?
        "https://api-3t.sandbox.paypal.com/nvp"
      else
        "https://api-3t.paypal.com/nvp"
      end
    end

    def url_paypal
      if sandbox?
        "https://www.sandbox.paypal.com/cgi-bin/webscr"
      else
        "https://www.paypal.com/cgi-bin/webscr"
      end
    end

    def url_return
      @url_return ||= "#{full_url}/ic_paiement/main?op=ok"
    end

    def url_cancel
      @url_cancel ||= "#{full_url}/ic_paiement/main?op=cancel"
    end

    def data_key
      {
        PAYMENTREQUEST_0_CURRENCYCODE:    "EUR",
        PAYMENTREQUEST_0_PAYMENTACTION:   "SALE",
        cancelUrl:                        url_cancel,
        returnurl:                        url_return
      }
    end

    def full_url
      @full_url ||= begin
        sandbox? ? App.config.local_full_url : 'http://www.atelier-icare.net'
      end
    end

    def data_account
      @data_account ||= begin
        if sandbox?
          PAYPAL[:sandbox_account]
        else
          PAYPAL[:live_account]
        end
      end
    end

    def params_authentification_paiement
      @params_authentification_paiement ||= begin
        {
          'USER'      => CGI::escape(data_account[:username]),
          'PWD'       => data_account[:password],
          'SIGNATURE' => data_account[:signature],
          'VERSION'   => "119"
        }
      end
    end


  end # << self
end #/IcPaiement
