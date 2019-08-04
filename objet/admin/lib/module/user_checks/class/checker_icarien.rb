=begin
  Méthodes de check de l'icarien

  Propriétés utiles et méthodes de check

=end
class Admin
class Checker
class << self

  # Méthode qui check l'icarien
  def check_icarien
    Admin::Checker::Icarien.new(icarien).check
  end

  def icarien
    @icarien || (icarien_id && User.get(icarien_id.to_i))
  end
  def icarien_id
    @icarien_id || param(:icarien_id)
  end
  def data_user
    @data_user ||= begin
      site.db_execute('users', "SELECT * FROM users WHERE id = #{icarien_id}")[0]
    end
  end

end #<<self Admin::Checker

class Icarien

  require_relative '_module_messages'
  require_relative '_module_props'
  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

  attr_reader :instance_user

  # icarien est l'instance User de l'icarien
  def initialize icarien
    @instance_user = icarien
  end

  def id          ; @id           ||= instance_user.id            end
  def pseudo      ; @pseudo       ||= instance_user.pseudo        end
  def options     ; @options      ||= instance_user.options       end
  def alessai?    ; @isalessai    ||= instance_user.alessai?      end
  def actif?      ; @is_actif     ||= instance_user.actif?        end
  def bit_state   ; @bit_state    ||= instance_user.bit_state     end
  def en_attente? ; @isenattente  ||= instance_user.en_attente?   end

  def check

    add_title "Check de #{pseudo} (##{id})"
    add_info 'Pseudo', "#{pseudo.in_span(class: 'bold')}"
    add_info 'ID', "#{"##{id}".in_span(class: 'bold')}"

    ok = options_in_db == icarien.options
    add_check 'Options (DB)', "#{options_in_db}", ok
    unless ok
      add_error "La valeur des options ne correspond pas, entre la base et la méthode"
      add 'Options MT', "#{options}"
      add 'Options DB', options_in_db
    end
    ok = bit_state_db == bit_state
    add_check 'Bit d’état', "DB:#{bit_state_db} MT:#{bit_state}",  ok
    add_error("Le bit d'état devrait correspondre.") unless ok

    ok = actif? === (bit_state_db == 2)
    add_check 'Actif ?', "MT:#{actif? ? 'OUI' : 'NON'} DB:#{bit_state_db == 2 ? 'OUI' : 'NON'}", ok
    add_error "La valeur du bit d'état pose un problème" unless ok

    if actif?
      check_icarien_as_actif
    elsif icarien.alessai?
      check_icarien_a_l_essai
    elsif en_attente?
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

    check_all_watchers_icarien

  end

  # On check tous les watchers de l'icarien et on signale les watchers
  # incohérent
  def check_all_watchers_icarien
    watchers = site.db_execute('hot',"SELECT * FROM watchers WHERE user_id = #{id}")
    # pas de problème s'il n'y a aucun watcher (quoi que…)
    return if watchers.count === 0
    watchers.each do |hwatcher|
      add 'Watcher', hwatcher.inspect
    end
  end


  # Check de l'icarien lorsqu'il est actif
  def check_icarien_as_actif
    add_title '⇒ Check Icarien actif'
    # L'icarien a-t-il un module défini dans son enregistrement
    @_icmodule_id = data[:icmodule_id]

    # TEST Pour générer l'erreur suivante
    @_icmodule_id = nil

    if @_icmodule_id
      icmodule = Admin::Checker::IcModule.new(@_icmodule_id)
      add 'IcModule ID', icmodule.id
    else
      add_error "Pas de icmodule_id dans la donnée de l'user…"
      add_action "Je cherche un icmodule pour cet icarien…"
      @data_icmodule = found_icmodule
      if @data_icmodule
        @_icmodule_id = @data_icmodule[:id]
        sol_id  = 'user-set-icmodule_id'
        sol_msg = "IcModule #{@_icmodule_id} trouvé. Réparer user#icmodule_id avec cette valeur."
        correct(sol_id, sol_msg, 'users','users', id, 'icmodule_id', @_icmodule_id)
      else
        add_error "Aucun icmodule trouvé, je dois renoncer. GRAVE ERREUR."
        sol_msg = "L'icarien doit être marqué inactif."
        @new_options[16] = 4
        correct('user-set-inactif', sol_msg, 'users','users', id, 'options', new_options)
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
  #   Méthodes de correction

  # Recherche un icmodule pour l'icarien courant
  # On prend le dernier trouvé, ou rien
  def found_icmodule
    icmodules = site.db_execute('modules',"SELECT * FROM icmodules WHERE user_id = #{id} ORDER BY created_at ASC")
    # On boucle sur les modules pour en trouver un qui n'est pas fini, sinon,
    # on prend le dernier
    candidats     = []
    lastest_date  = 0
    last_icmodule = nil
    icmodules.each do |icmodule|
      if icmodule[:options][0].to_i < 3
        # => Canditat possible
        candidats << icmodule
      elsif lastest_date < (icmodule[:started_at] || icmodule[:created_at])
        last_icmodule = icmodule
        lastest_date  = icmodule[:started_at] || icmodule[:created_at]
      end
    end

    if candidats.empty?
      last_icmodule
    else
      candidats.last # ils sont classés par date de création (<)
    end
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
    @options_in_db ||= data[:options]
  end
  def options_by_method
    @options_by_method ||= options
  end

  def data
    @data ||= begin
      site.db_execute('users', "SELECT * FROM users WHERE id = #{id}")[0]
    end
  end

end #/Icarien
end #/Checker
end #/Admin
