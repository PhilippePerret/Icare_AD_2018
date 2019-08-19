# encoding: UTF-8
=begin
Méthodes de statut pour l'utilisateur (courant ou autre)
=end
class User

  # Pour admin?, super? et manitou?,
  # cf. le fichier inst_options.rb
  # Rappel : Seuls les bits de 0 à 15 peuvent être utilisés par
  # le rest-site (la base). Les bits de 16 à 31 sont réservés à
  # l'application elle-même. Cf. le fichier ./_objet/site/config.rb
  # qui définit ces valeurs de l'application.

  def exist?
    return false if @id.nil?
    where = "(id = #{id}) AND (options NOT LIKE '___1%')"
    table.count(where:where) > 0
  end

  def destroyed?
    bit_destroyed == 1
  end

  def guest?
    @id == nil
  end

  # Return true si le visiteur est une femme
  def femme?
    identified? && sexe == 'F'
  end
  alias :fille? :femme?
  # Return true si le visiteur est un homme
  def homme?
    !identified? || sexe == 'H'
  end
  alias :garcon? :homme?

  def identified?
    (@id != nil) || moteur_recherche?
  end

  # Retourne true si l'user est à jour de ses paiements
  # Pour qu'il soit à jour, il faut qu'il ait un paiement qui
  # remonte à moins d'un an.
  #
  # Un icarien actif est toujours considéré comme
  # abonné.
  #
  # Alias : def subscribed?
  def paiements_ok?
    return true   if moteur_recherche? || icarien_actif?
    return false  if @id.nil? # Un simple visiteur
    now = Time.now
    anprev = Time.new(now.year - 1, now.month, now.day).to_i
    !!(last_abonnement && last_abonnement > anprev)
  end
  alias :paiement_ok? :paiements_ok?
  alias :subscribed? :paiements_ok?

  # Cette propriété est mise à true lorsque l'user vient de
  # s'inscrire, qu'il devrait confirmer son mail, mais qu'il
  # doit payer son abonnement. On a mis alors `for_paiement` à
  # "1" dans ses variables de session, si qui lui permet de
  # passer outre la confirmation.
  # Noter que 'for_paiement' sera détruit après le paiement pour
  # obliger l'user à confirmer son mail.
  def for_paiement?
    @for_paiement ||= param(:for_paiement) == "1"
  end

  # Renvoie true si l'user est abonné depuis au moins +nombre_mois+
  # au site. False dans le cas contraire.
  # Par défaut 6 mois.
  def abonnement_recent?(nombre_mois = 6)
    return false if @id.nil? # pour guest
    # Pour les moteurs de recherche, les icariens actifs,
    # i.e. tous les gens qui ne paient pas d'abonnement mais
    # peuvent tout voir.
    return false if last_abonnement.nil?
    last_abonnement > (Time.now.to_i.to_i - (30.5*nombre_mois).to_i.days)
  end


end
