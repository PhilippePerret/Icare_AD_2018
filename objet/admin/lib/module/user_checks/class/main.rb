class Admin
class << self
  def output
    @msg = []
    if icarien_id
      @msg << "Je dois vérifier l'icarien #{icarien.pseudo} ##{icarien_id}".in_div
      check_icarien
    else
      @msg << "Choisir l'icarien à checker".in_div
    end
    return @msg.join('')
  end

  # Méthode qui check l'icarien
  def check_icarien

    @msg << "Pseudo : #{icarien.pseudo} (##{icarien.id})".in_div(class:'bold')
    @msg << "Statut : #{icarien.bit_state} (bit option)"
    @msg << "Actif ?  #{icarien.actif? ? 'OUI' : 'NON'}"

    check_icarien_as_actif

    # icarien.alessai? => doit retourner true s'il est à l'essai (d'après ses bits)
    # icarien.real_icarien? => doit retourner true si un 1er paiement a été effectué (d'après le bit option)
    # icarien.icarien? => doit retourne true si inscrit et reçu ou non
    # icarien.en_attente? => true si le bit option dit qu'il est en attente
    # icarien.recu? => true si vient de s'inscrire et est reçu
    # icarien.actif? => true s'il a un module
    #  => implique des checks plus poussés
    # icarien.en_pause? => true s'il est en pause
    #   => des tests plus poussés
    # icarien.inactif? => true s'il est inactif d'après ses bits

  end


  # Check de l'icarien lorsqu'il est actif
  def check_icarien_as_actif
    # L'icarien a-t-il un module défini dans son enregistrement
    # Si oui => OK et on poursuit
    # Si non => c'est une grave erreur
    #     => on essaie de trouver un module courant dans la table des modules

    # Est-ce un module à durée déterminée ?
    # Si oui
    #   => test DES paiements
    #   => y a-t-il un watcher correspondant à ce module ?
    #     => Si oui, est-il valide ?
    #     => Si non
    #       => voir si un watcher correspond à un module de l'icarien
    #         => Si oui, proposer de le corriger
    #         => Si non, proposer de le créer

    # Si non => test DU paiement
    #   S'il y a un paiement, correspond-il
  end


  # --- Propriétés pour simplifier le code

  def icarien
    @icarien || (icarien_id && User.get(icarien_id.to_i))
  end
  def icarien_id
    @icarien_id || param(:icarien_id)
  end

  def menu_icariens
    ([[0, 'Choisir l’icarien…']] + User.values_select('all' => true)).in_my_select(id: 'icarien_id', name: 'icarien_id', selected: param(:icarien_id))
  end

end #/<< self
end #/Admin
