# encoding: UTF-8

class User



  def test_create_paiement objet = 'ABONNEMENT', montant = site.tarif
    User.table_paiements.insert(
      user_id:      self.id,
      objet_id:     objet,
      montant:      montant,
      facture:      'EC-38P44270A5110' + (rand(10000)).rjust(4,'0'),
      created_at:   Time.now.to_i - rand(20000)
    )
  end

end # /User
