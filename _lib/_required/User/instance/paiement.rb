# encoding: UTF-8
=begin

Toutes les méthodes concernant les paiements

=end
class User


  # {Integer} Date (timestamp) de prochain paiement
  # Noter que cette méthode, pour le moment, ne doit être appelée
  # que si l'user a déjà procédé à un paiement.
  def next_paiement
    @next_paiement ||= begin
      raise "ID devrait être défini pour checker le paiement" if @id.nil?
      last_paiement = User::table_paiements.select(where:{user_id: id, objet_id: "ABONNEMENT"}, order:"created_at DESC", limit:1, colonnes:[:created_at]).first[:created_at]
      dlast = Time.at(last_paiement)
      Time.new(dlast.year + 1, dlast.month, dlast.day).to_i
    end
  end

  # Retourne le timestamp Integer du dernier paiement
  # pour un abonnement au site
  def last_abonnement
    @last_abonnement ||= begin
      if @id != nil && User::table_paiements.exists?
        la = User::table_paiements.select(where:"user_id = #{id} AND ( objet_id = 'ABONNEMENT' OR objet_id = '1AN1SCRIPT' )", order: "created_at DESC", limit:1, colonnes:[:created_at]).first
        la[:created_at] unless la.nil?
      end
    end
  end

  # Méthode appelée tout de suite après l'enregistrement d'un
  # paiement dans la table des paiements.
  def on_paiement data_paiement
  end

end
