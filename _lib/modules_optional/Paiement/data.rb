# encoding: UTF-8
class SiteHtml
class Paiement

  # {Float} Le montant du paiement
  # Il doit être défini dans le Hash qui est envoyé à la
  # méthode `make_transaction`
  attr_reader :montant

  # {String} L'objet du paiement, par exemple le paiement
  # de l'abonnement au site.
  # Doit absolument être défini dans le Hash qui est
  # envoyé à la méthode `make_transaction`
  attr_reader :objet

  # Pour connaitre l'objet du paiement dans la table de données
  # des paiements, propriété de même nom.
  # Il faut transmettre cette donnée dans le Hash qui est donné
  # en argument de make_transaction.
  attr_reader :objet_id

  # Définir le contexte du paiement, lorsque ce n'est pas un paiement
  # pour le site lui-même, mais pour une sous-section.
  # Ce contexte est le dossier à partir de "./_objet".
  #
  # @usage
  #   Définir la propriété :context dans le hash envoyé
  #   à la méthode make_transaction :
  #     site.paiement.make_transaction(montant: 120, context: "unan", ...)
  #
  attr_reader :context

  # {String} Le token de la transaction
  # C'est la méthode qui le définit en utilisant la
  # tournure :
  #   @token = command.token
  # avec `command` qui est la transaction effectuée
  # Elle peut également le récupérer dans l'url au
  # retour du paiement
  attr_reader :token

  # {String} Le PayerId de la transaction
  attr_reader :payer_id

  # {String} La description du paiement, au cas où
  attr_accessor :description


  # Le montant à payer, au format humain
  def montant_humain
    @montant_humain ||= montant.as_tarif
  end

  # {String} Le montant en version Paypal
  # C'est une version avec les centimes mais sans devise
  def montant_paypal
    @montant_paypal ||= begin
      case montant
      when Integer then "#{montant}.00"
      else "#{montant}"
      end
    end
  end

  # Data enregistrées dans la base de données pour
  # le paiement (table users.paiements)
  def data_paiement
    @data_paiement ||= {
      user_id:    user.id,
      objet_id:   objet_id,
      montant:    montant,
      facture:    token,
      created_at: Time.now.to_i
    }
  end

  def data_key
    @data_key ||= {
      PAYMENTREQUEST_0_CURRENCYCODE:    "EUR",
      PAYMENTREQUEST_0_PAYMENTACTION:   "SALE",
      CANCELURL:                        url_retour_cancel,
      RETURNURL:                        url_retour_ok
    }
  end

end #/Paiement
end #/SiteHtml
