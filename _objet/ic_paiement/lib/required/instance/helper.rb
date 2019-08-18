# encoding: UTF-8
class IcPaiement

  # Code HTML de la facture, pour l'affichage sur le site et
  # pour l'envoi dans le mail
  def facture_html
    poss      = "Atelier Icare (www.atelier-icare.net)"
    now_hum   = Time.now.strftime("%d %m %Y")
    objetname = 'Module d\'apprentissage'
    tarifh    = "#{abs_module.tarif}.00 €"
    client    = "#{owner.patronyme} (N°#{owner.id})"
    (
      ('N° Facture'.in_td   + facture.in_td         ).in_tr +
      ('Délivrée le'.in_td  + now_hum.in_td         ).in_tr +
      ('Délivrée par'.in_td + poss.in_td            ).in_tr +
      ('Pour'.in_td         + client.in_td          ).in_tr +
      ('Objet'.in_td        + objetname.in_td       ).in_tr +
      ('Désignation'.in_td  + abs_module.name.in_td ).in_tr +
      ('Montant TTC'.in_td  + tarifh.in_td          ).in_tr
    ).in_table(
      id: 'facture', border:0, cellspacing: 5, cellpadding: 5,
      style: 'background-color:#EFEFFF'
      )
  end
end #/IcPaiement
