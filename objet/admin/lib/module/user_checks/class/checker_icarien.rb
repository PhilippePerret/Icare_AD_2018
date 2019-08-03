=begin
  Méthodes de check de l'icarien

  Propriétés utiles et méthodes de check

=end
class Admin
class Checker
class << self

  # Méthode qui check l'icarien
  def check_icarien
    add_title "Check de #{icarien.pseudo} (##{icarien.id})"
    add 'Pseudo', "#{icarien.pseudo}", {class: 'bold'}
    add 'ID', "##{icarien.id}", {class: 'bold'}
    ok = options_in_db == icarien.options
    add_check 'Options (DB)', "#{options_in_db}", ok
    unless ok
      add_error "La valeur des options ne correspond pas, entre la base et la méthode"
      add 'Options MT', "#{icarien.options}"
      add 'Options DB', options_in_db
    end
    ok = bit_state_db == icarien.bit_state
    add_check 'Bit d’état', "DB:#{bit_state_db} MT:#{icarien.bit_state}",  ok
    add_error("Le bit d'état devrait correspondre.") unless ok

    ok = icarien.actif? === (bit_state_db == 2)
    add_check 'Actif ?', "MT:#{icarien.actif? ? 'OUI' : 'NON'} DB:#{bit_state_db == 2 ? 'OUI' : 'NON'}", ok
    add_error "La valeur du bit d'état pose un problème" unless ok

    if icarien.actif?
      check_icarien_as_actif
    elsif icarien.alessai?
      check_icarien_a_l_essai
    elsif icarien.en_attente?
      check_icarien_en_attente
    end
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
    add_title 'Check Icarien actif'
    # L'icarien a-t-il un module défini dans son enregistrement
    @_icmodule_id = data_user_in_db[:icmodule_id]
    if @_icmodule_id
      icmodule = Admin::Checker::IcModule.new(@_icmodule_id)
      add 'IcModule ID', icmodule.id
    else
      add_error "Pas de icmodule_id dans la donnée de l'user…"
      add_action "Je cherche un icmodule pour cet icarien…"
      @data_icmodule = check_for_icmodule
      if @data_icmodule
        @_icmodule_id = @data_icmodule[:id]
        add_solution "IcModule #{@_icmodule_id} trouvé. Corriger la propriété icmodule_id de l'user avec cette valeur."
        correct('users','users', icarien.id, 'icmodule_id', @_icmodule_id)
      else
        add_error "Aucun icmodule trouvé, je dois renoncer. GRAVE ERREUR."
        add_solution "L'icarien doit être marqué inactif."
        @new_options[16] = 4
        correct('users','users', icarien.id, 'options', new_options)
        return
      end
    end

    Admin::Checker::IcModule.check_icmodule_as_current(@_icmodule_id)

  end

  # Les nouvelles options pour l'icarien
  #
  # Cette donnée peut être utilisée par plusieurs corrections, c'est donc en
  # donnée finale qu'elle sera prise.
  def new_options
    @new_options
  end

  def check_icarien_a_l_essai
    add_error 'Je ne sais pas encore traiter un icarien à l’essai.'
  end
  def check_icarien_en_attente
    add_error "Je ne sais pas encore traiter un icarien en attente."
  end


  # ---------------------------------------------------------------------
  # ---------------------------------------------------------------------
  # ---------------------------------------------------------------------
  #   Méthodes de données
  def icmodule_id
    @_icmodule_id
  end

  def bit_state_db
    @bit_state_db ||= options_in_db[16].to_i
  end
  def options_in_db
    @options_in_db ||= data_user_in_db[:options]
  end
  def options_by_method
    @options_by_method ||= options
  end

  def data_user_in_db
    @data_user_in_db ||= begin
      h = site.db_execute('users', "SELECT * FROM users WHERE id = #{icarien.id}")[0]
      # debug "data_user_in_db: #{h.inspect}"
      h
    end
  end
  alias :data_user :data_user_in_db

  def icarien
    @icarien || (icarien_id && User.get(icarien_id.to_i))
  end
  def icarien_id
    @icarien_id || param(:icarien_id)
  end


end #/<< self
end #/Checker
end #/Admin
