=begin
  Méthodes pour les checks des modules
=end
class Admin
class Checker
class IcModule

  require_relative '_module_messages'
  require_relative '_module_props'
  require_relative '_module_handy'
  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

class << self

  # Check de l'icmodule courant
  def check_icmodule_as_current(icarien, icmodule_id)
    new(icarien, icmodule_id).check_as_current
  end

end #/self

  attr_reader :id, :icarien

  def initialize icarien, id
    @icarien  = icarien # instance Admin::Checker::Icarien
    @id       = id
  end

  def check_as_current
    add_title "⇒ 🦋 Check du module d’apprentissage ##{id} en tant que module courant de #{icarien.pseudo}"

    add_info 'Création',   fdate(data[:created_at])
    add_info 'Démarrage',  fdate(data[:started_at])

    # TEST Pour tester l'erreur :
    # data[:ended_at] = Time.now.to_i

    unless data[:ended_at].nil?
      add_fatal_error "Le ended_at du module devrait être null, si c'est le module courant…"
    end

    # TEST Pour générer l'erreur
    # @created_at = data_user[:created_at] - 1000

    if data_user[:created_at] > created_at
      add_error "La date de création du module est inférieure à l'inscription de l'icarien…"
      sol_msg = "Mettre sa date de création après la date d'inscription de l'icarien."
      @created_at = data[:created_at] = data_user[:created_at] + 1000
      correct('ctime-to-ctime_inscription', sol_msg, 'modules', 'icmodules', id, 'created_at', data_user[:created_at] + 1000)
    end

    # TEST Pour générer l'erreur
    # @created_at = updated_at + 1000

    if created_at > updated_at
      add_error "La date de création du module est supérieur à sa date de dernière modification…"
      sol_msg = "Mettre sa date de création à sa date de dernière modification."
      @created_at = data[:created_at] = updated_at
      correct('dcm-to-dum', sol_msg, 'modules', 'icmodules', id, 'created_at', updated_at)
    end

    # TEST Pour générer l'erreur
    # data[:user_id] = 12

    user_id_ok = data[:user_id] == icarien.id
    add_check 'Icarien', "Courant:#{icarien.id} Module:#{data[:user_id]}", user_id_ok

    unless user_id_ok
      add_error "Le user_id du module est mauvais (#{data[:user_id]} au lieu de #{icarien.id})"
      sol_msg = "Mettre #{icarien.id}"
      correct('fix-module-user_id', sol_msg, 'modules','icmodules', id, 'user_id', icarien.id)
    end

    # Si c'est un module à durée indéterminée
    check_module_as_suivi if module_suivi?

  end


  def check_module_as_suivi
    add_title "Check du module d’apprentissage ##{id} en tant que module de suivi"

    # Vérification de la date de prochain paiement
    # --------------------------------------------
    check_next_paiement_module_suivi

    # Vérification de l'étape courante du module de suivi
    # ----------------------------------------------------
    Admin::Checker::IcEtape.check_current_etape_module_suivi(self)

  end


  def check_next_paiement_module_suivi
    # Pour générer une erreur
    # data[:next_paiement] = nil

    if next_paiement.nil?
      # Si le module n'est pas encore démarré, c'est normal qu'il n'y ait pas
      # de date de prochain paiement.
      unless options[0].to_i < 1
        add_error "Aucune date de prochain paiement trouvée."
        @next_paiement = data[:next_paiement] = calcTimeNextPaiement
        sol_msg = "Mettre la date de paiement au #{fdate next_paiement} (#{raison_time_next_paiement})."
        correct('next-paiement', sol_msg, 'modules','icmodules', id, 'next_paiement', next_paiement)
      end
    end

    # Existe-t-il un watcher pour ce prochain paiement ?
    # --------------------------------------------------

    condition = "user_id = #{icarien.id} AND objet = 'ic_module' AND objet_id = #{id} AND processus = 'paiement'"
    watchers_paiement = site.db_execute('hot',"SELECT * FROM watchers WHERE #{condition} ORDER BY created_at ASC")

    # TEST Pour générer la première erreur (pas de watcher)
    # watchers_paiement = []

    # TEST Pour générer la seconde erreur (trop de watchers)
    # if watchers_paiement.empty?
    #   watchers_paiement = [{id:1, user_id: icarien.id, objet:'ic_module', objet_id:id, processus:'paiement'}]
    # end
    # new_watcher = watchers_paiement[0].dup
    # new_watcher[:id] = 1200000
    # watchers_paiement.unshift(new_watcher)
    # new_watcher = new_watcher.dup
    # new_watcher[:id] = 1200023
    # watchers_paiement << new_watcher
    # /FIN TEST

    if watchers_paiement.count == 0
      time_next_paiement = calcTimeNextPaiement
      add_error "Aucun watcher de prochain paiement n'existe pour ce module."
      sol_msg = "Ajouter un watcher de prochain paiement en date du #{fdate(time_next_paiement)} (#{raison_time_next_paiement})."
      watcher_next_paiement = {user_id: icarien.id, objet:'ic_module', objet_id:id, triggered:time_next_paiement, created_at:now, updated_at:now}
      correct('add-watcher-paiement', sol_msg, 'hot','watchers', nil, watcher_next_paiement)
    elsif watchers_paiement.count > 1
      # Trop de watchers de paiement
      add_error "Il y a trop de watchers de paiements pour ce module."
      # On enlève le dernier et on supprime tous les autres
      watcher_next_paiement = watchers_paiement.pop
      first_id_watchers_paiement = watcher_next_paiement[:id]
      sol_msg = "Ne garder que le dernier watcher de paiement (##{first_id_watchers_paiement}) et supprimer les autres (#{watchers_paiement.collect{|h|h[:id]}.join(', ')})."
      watchers_paiement.each do |hwatcher|
        correct("uniq-watcher-paiement-#{hwatcher[:id]}", sol_msg, 'hot', 'watchers', hwatcher[:id], 'DELETE')
      end
    else
      watcher_next_paiement = watchers_paiement[0]
    end

    # On efface ce watcher
    if watcher_next_paiement[:id]
      icarien.all_watchers.delete(watcher_next_paiement[:id])
    end

    # TEST Pour générer la première erreur
    # watcher_next_paiement[:triggered] = now - 90.days

    # TEST Pour générer la seconde erreur
    # watcher_next_paiement[:triggered] = now + 90.days

    # On regarde quand même pour voir si la date n'est pas absurde, c'est-à-dire
    # trop ancienne ou trop dans le futur (plus de deux mois)
    trigtime = watcher_next_paiement[:triggered]
    if trigtime < now - 30.days || trigtime > now + 60.days
      if trigtime < now - 30.days
        add_error "La date de prochain paiement est révolue depuis trop longtemps (#{dateof(trigtime)})."
      elsif trigtime > now + 60.days
        add_error "La date de prochain paiement est trop lointaine dans le futur (#{dateof(trigtime)})"
      end
      new_trig_time = now + 20.days
      if watcher_next_paiement[:id]
        # Seulement si l'id du watcher est défini, donc qu'il existe
        # Sinon, il faudra passer une première fois créer le nouveau watcher et
        # une seconde pour obtenir son ID
        sol_msg = "Mettre une date de prochain paiement plus cohérente (20 jours à partir de maintenant => #{Time.at(new_trig_time).strftime('%d %m %Y')})."
        correct('rectif-next-paiement-time', sol_msg, 'hot', 'watchers', watcher_next_paiement[:id], 'triggered', new_trig_time)
      end
    end

  end

  # ---------------------------------------------------------------------
  #   Méthodes de données

  # Retourne une date de prochain paiement réaliste. Elle est calculée en
  # priorité sur la date du dernier paiement, mais si cette date n'existe pas
  # ou est trop lointaine, on se sert de la date courante
  def calcTimeNextPaiement
    if last_paiement_time && (last_paiement_time + 30.days > now)
      @raison_time_next_paiement = "calculé d'après le dernier paiement"
      return last_paiement_time + 30.days
    elsif data[:paiements].to_s == ''
      if data[:started_at] + 31.days > now
        @raison_time_next_paiement = "calculé d'après la date de démarrage du module"
        return data[:started_at] + 31.days
      end
    end
    # Sinon, on la calcule à partir de maintenant
    @raison_time_next_paiement = "calculé à partir de la date courante"
    now + 5.days
  end

  # Retourne la raison qui a permis de calculer la date de prochain paiement
  # Note : défini dans calcTimeNextPaiement ci-dessus
  def raison_time_next_paiement; @raison_time_next_paiement end

  # Méthode qui cherche un icmodule pour l'icarien, qui aurait son ended_at à
  # null, signifiant qu'il n'est pas terminé.
  # Cette méthode est appelée lorsque la propriété id de l'user n'est
  # pas définie alors qu'il est actif.
  def check_for_icmodule
    icmodules = site.db_execute('modules', "SELECT * FROM icmodules WHERE user_id = #{icarien.id} AND ended_at IS NULL ORDER BY created_at DESC")
    # debug "icmodules: #{icmodules.inspect}"
    return icmodules.first
  end

  # --- Propriétés pour simplifier le code

  # Retourne true si c'est un module de suivi
  def module_suivi?
    @is_module_suivi ||= data_absmodule[:nombre_jours].nil?
  end

  # Retourne, si elle existe, la date de dernier paiement
  def last_paiement_time
    @last_paiement_time ||= begin
      if data[:paiements].to_s != ''
        id_last_paiement = data[:paiements].split(' ').last.to_i
        site.db_execute('users',"SELECT created_at FROM paiements WHERE id = #{id_last_paiement}",)[0][:created_at]
      end
    end
  end

  # Retourne les données de l'IcModule du module courant de l'icarien, ou null
  # s'il n'existe pas
  def data
    @data ||= begin
      if id
        site.db_execute('modules', "SELECT * FROM icmodules WHERE id = #{id}")[0]
      else
        nil
      end
    end
  end

  def data_absmodule
    @data_absmodule ||= begin
      site.db_execute('modules',"SELECT * FROM absmodules WHERE id = #{abs_module_id}")[0]
    end
  end
  def abs_module_id
    @abs_module_id ||= data[:abs_module_id]
  end
  def icetape_id
    @icetape_id ||= data[:icetape_id]
  end
  def icetapes
    @icetapes ||= data[:icetapes]
  end
  def options
    @options ||= data[:options]
  end
  def next_paiement
    @next_paiement ||= data[:next_paiement]
  end
  def started_at
    @started_at ||= data[:started_at]
  end
  def ended_at
    @ended_at ||= data[:ended_at]
  end
  def created_at
    @created_at ||= data[:created_at]
  end
  def updated_at
    @updated_at ||= data[:updated_at]
  end

end #/IcModule
end #/Checker
end #/Admin
