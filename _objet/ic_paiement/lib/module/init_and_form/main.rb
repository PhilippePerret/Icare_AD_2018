# encoding: UTF-8
=begin

  Module principal lorsque l'on arrive sur la page de paiement, pour
  initier le paiement et présenter le formulaire.

=end
class IcPaiement

  # Méthode appelant SetExpressCheckout pour définir le paiement, afin de
  # définir l'action du formulaire du bouton PayPal. Note : L'icarien n'est
  # pas encore sur la page de paiement, elle lui sera affichée à la fin de
  # ce processus.
  def init
    # avant : @paiement_montant
    @montant  = "#{abs_module.tarif}.00"
    # avant : @paiement_description
    @objet    = "Objet : paiement du module d'apprentissage “#{abs_module.name}”."
    # On soumet la requête Curl
    curl_response = `#{request_set_express_checkout}`
    # Décomposition de la requête
    curl_response = reponse_paypal_to_hash(curl_response)
    # Succès ou failure ?
    curl_response[:ack] != "Failure" || raise('Un problème est malheureusement survenu.')
    # En cas de succès, on mémorise le token
    @token = curl_response[:token]
  rescue Exception => e
    debug e
    page_when_erreur(e)
  else
    formulaire_de_paiement
  end


  def request_set_express_checkout
    querystring =
      self.class.params_authentification_paiement.collect do |name, value|
        "#{name}=#{value}"
      end
    data_paiement = Hash.new
    data_paiement.merge!( self.class.data_key )
    data_paiement.merge!(
      method:                 "SetExpressCheckout",
      localecode:             "FR",
      cartbordercolor:        "008080",
      paymentrequest_0_amt:   montant,
      paymentrequest_0_qty:   "1"
    )
    data_paiement.each{|name, value| querystring << "#{name.upcase}=#{CGI::escape value}"}

    # On finalise le querystring qui sera transmis par CURL
    querystring = querystring.join('&')

    # On construit la commande qui va initier le paiement
    #
    # En mode Sandbox, on utilise l'option '--insecure' (requête non
    # sécurisée) pour contourner la recherche de certificat. En mode
    # live, on utilise l'adresse sécurisée, avec le certificat.
    #
    command =
      if sandbox?
        "curl -s --insecure #{self.class.url_paypal_nvp} -d \"#{querystring}\""
      else
        "curl -s #{self.class.url_paypal_nvp} -d \"#{querystring}\""
      end
    return command
  end

end #/IcPaiement
