# encoding: UTF-8
=begin
  Module
=end
class IcPaiement

  # {Hash} Détails du paiement
  attr_reader :details
  # {Hash} Réponse de confirmation du paiement
  attr_reader :data_confirmation

  # = main =
  #
  # Méthode principale exécutée quand on revient du paiement PayPal et
  # que l'user n'a pas annulé.
  #
  # RETURN Le code HTML à afficher dans la page.
  def on_ok
    app.benchmark('-> IcPaiement#on_ok')
    # Récupérer les détails de l'opération
    get_details_paiement

    # Confirmation du paiement
    confirme_paiement

    if confirmation_ok?

      enregistrer_paiement_module
      run_watcher_paiement_if_any
      app.benchmark('<- IcPaiement#on_ok')
      page_on_confirmation_ok

    else
      # En cas d'échec de la confirmation du paiement
      app.benchmark('<- IcPaiement#on_ok')
      page_on_confirmation_not_ok

    end

  rescue Exception => e
    debug "# ERREUR EN CONFIRMANT UN PAIEMENT"
    debug e
    debug "Full command envoyée : #{request_confirm_paiement}"
    debug "# Retour de l'opération : #{data_confirmation.inspect}"
    app.benchmark('<- IcPaiement#on_ok (ERROR)')
    page_on_error_operation(e)
  end
  # /on_ok

  def confirme_paiement
    @data_confirmation = reponse_paypal_to_hash `#{request_confirm_paiement}`
  end

  def confirmation_ok?
    data_confirmation[:ack] == 'Success'
  end


  # Quand tout s'est bien passé et que l'user a procédé à son paiement, on
  # doit runner le watcher de paiement pour terminer les actions
  def run_watcher_paiement_if_any
    app.benchmark('-> IcModule#run_watcher_paiement_if_any')
    # On doit trouver le watcher
    hwatcher = site.dbm_table(:hot, 'watchers').get(where: {user_id: owner.id, processus: 'paiement'})
    hwatcher != nil || raise('Impossible de trouver un watcher de paiement pour vous…')
    # Le watcher de paiement aura peut-être besoin de l'identifiant
    # du nouveau paiement, on le met dans les paramètres.
    param(paie_id: self.id)
    debug "param(:paie_id) =  #{param(:paie_id).inspect}"
    self.id != nil || raise('L’identifiant du paiement ne devrait pas être nil…')
    site.require_objet 'watcher'
    SiteHtml::Watcher.new(hwatcher[:id]).run
    app.benchmark('<- IcModule#run_watcher_paiement_if_any')
  end

  def enregistrer_paiement_module
    icmodule.id != nil || raise('icmodule.id ne doit pas être nil…')
    data_paiement = {
      user_id:      user.id,
      icmodule_id:  icmodule.id,
        # Note : ne surtout pas utiliser `icmodule_id` ici, qui serait
        # la propriété du IcPaiement. Il faut impérativement utiliser
        # la méthode `icmodule` qui surclasse dans (main.rb) celle par
        # défaut (dans data.rb)
      objet:        "Module “#{abs_module.name}” (##{abs_module.id})",
      montant:      abs_module.tarif.to_f.round(2),
      facture:      token,
      created_at:   Time.now.to_i
    }
    @id = User.table_paiements.insert(data_paiement)
    data_paiement.each{|k,v|instance_variable_set("@#{k}",v)}
    # =================================================
    # L'ENREGISTREMENT DU PAIEMENT SE FAIT VRAIMENT ICI
    # =================================================
    # On ajoute ce paiement au module
    icmodule.add_paiement @id
  end

  # Définit les détails du paiements (@details)
  #
  def get_details_paiement
    @details = reponse_paypal_to_hash(`#{request_details_paiement}`)
  end

  # ---------------------------------------------------------------------
  #   Les requêtes CURL
  # ---------------------------------------------------------------------


  # La requête pour confirmer le paiement
  def request_confirm_paiement
    querystring = []
    # Les paramètres d'authentification qui permettent de
    # reconnaitre qu'il s'agit bien de la commande qu'on
    # passe.
    self.class.params_authentification_paiement.each { |name, value| querystring << "#{name}=#{value}" }
    # Les paramètres de la transaction
    other_data = {
      method:         'DoExpressCheckoutPayment',
      token:          token,
      PayerID:        payer_id,
      currencycode:   details[:currencycode],
      amt:            details[:amt],
      PaymentAction:  "SALE"
    }.each {|n, v| querystring << "#{n.upcase}=#{v}"}
    querystring = querystring.join('&')
    # Retour en fonction du fait que c'est un test ou non
    if sandbox?
      "curl -s --insecure #{self.class.url_paypal_nvp} -d \"#{querystring}\""
    else
      "curl -s #{self.class.url_paypal_nvp} -d \"#{querystring}\""
    end
  end

  # La requête pour obtenir les détails du paiement (avant de le confirmer)
  def request_details_paiement
    # On ne donnera une réponse positive que si le retour est
    # successful.
    querystring = []
    # Les paramètres d'authentification
    self.class.params_authentification_paiement.each { |name, value| querystring << "#{name}=#{value}" }
    # Les paramètres de la transaction
    other_data = {
      method:         'GetExpressCheckoutDetails',
      token:          token,
      PayerID:        payer_id
    }.each {|n, v| querystring << "#{n.upcase}=#{v}"}

    querystring = querystring.join('&')
    "curl -s --insecure #{self.class.url_paypal_nvp} -d \"#{querystring}\""
  end


end#/IcPaiement
