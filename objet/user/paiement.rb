# encoding: UTF-8

# Des liens conduisent directement à ce formulaire de paiement
# Mais si l'utilisateur courant n'est pas encore inscrit, il
# faut au préalable qu'il s'inscrive au site. On le redirige
# donc vers le formulaire d'inscription.
# Sinon, on lui permet de s'inscrire par ici.
# Noter qu'après l'inscription, normalement, il faut valider d'abord
# son mail pour pouvoir poursuivre. Mais pour ce qui est du paiement,
# on login provisoirement l'user pour qu'il puisse procéder à son
# paiement et c'est seulement après qu'on lui demande de confirmer
# son mail.
unless user.identified?
  redirect_to 'user/signup'
else
  site.require_module 'paiement'

  # # La méthode de consignation du paiement
  # class SiteHtml::Paiement
  #   # Après validation du paiement, on peut l'enregistrer. En fait
  #   # cela consiste en trois opérations :
  #   #   1. Indiquer que l'user a payé en modifiant ses bits options
  #   #   2. Enregistrer le paiement dans la table des paiements
  #   #   3. Enregistrement dans la table des autorisations, pour la
  #   #      durée correspondant à l'abonnement.
  #   # def after_validation_paiement
  #   # end
  # end

  # Instancier un paiement et le traiter en fonction de
  # param(:pres)
  site.paiement.make_transaction(
    montant:      site.tarif,
    objet:        "Abonnement d'un an au site “#{site.name}”",
    objet_id:     "ABONNEMENT", # Pour la table
    description:  "paiement de l'abonnement d'un an" # pour le formulaire
  )
end
