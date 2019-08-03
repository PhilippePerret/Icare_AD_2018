=begin
  Méthodes pour les checks des modules
=end
class Admin
class Checker
class IcEtape

  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

class << self

  # Check de l'icmodule courant
  def check_current_etape_module_suivi icmodule
    new(icmodule).check_as_current_etape
  end

end #/<< self Admin::Checker::IcEtape

  attr_reader :id
  attr_reader :icmodule

  # param {Admin::Checker::IcModule} icmodule Module d'apprentissage testé
  def initialize icmodule
    @icmodule = icmodule
  end

  # Test de l'étape comme première étape du module courant
  def check_as_current_etape
    @id = icmodule.icetape_id
    add_title "🗂 Check de l'étape courante du module courant (##{icmodule.id})"
    add_info 'IcEtape ID', "##{id}"

    add_check '', "Cette ic-étape existe", exists?
    unless exists?
      add_fatal_error "L'ic-étape n'existe pas, je ne peux pas poursuivre."
      # TODO : trouver une étape qui peut correspondre
      return
    end

    # TEST Pour générer l'erreur suivante
    icmodule_id = 12

    ok = icmodule_id == icmodule.id
    success = "L'ic-module de l'étape est bien l'ic-module qui la contient"
    failure = "L'ic-module de l'étape devrait être ##{icmodule.id}, or c'est ##{icmodule_id}"
    add_check('IcModule', ok ? success : failure, ok)
    unless ok
      add_solution "set-module-etape-#{id}", "Mettre l'icmodule_id de l'étape à ##{icmodule.id}"
      correct('modules','icetapes', id, 'icmodule_id', icmodule.id)
    end

    # TEST Pour générer l'erreur suivante
    # @started_at = data[:started_at] = icmodule.started_at - 10.days

    unless start_after_start_module?
      add_error "La date de démarrage de l'étape est antérieure à la date de démarrage du module…"
      start_etape = icmodule.data[:started_at] + 1.day
      add_solution 'rectif-start-etape', "Mettre la date de démarrage de l'étape un jour après le démarrage du module (#{fdate(start_etape)})"
      correct('modules','icetapes', id, 'started_at', start_etape)
    end

    # # TEST Pour générer l'erreur suivante
    # # On supprime dans les anciennes étapes
    # icetapes = icmodule.icetapes.split(' ')
    # icetapes.delete(id.to_s)
    # icetapes = icetapes.join(' ')
    # icmodule.instance_variable_set('@icetapes', icetapes)
    # icmodule.data[:icetapes] = icetapes
    # # Si c'est l'étape courante, on la supprime
    # if id == icmodule.icetape_id
    #   icmodule.instance_variable_set('@icetape_id', nil)
    #   icmodule.data[:icetape_id] = nil
    # end
    # # /TEST

    # # TEST Pour supprimer en étape courante et ajouter dans la liste
    # # des anciennes étapes.
    # # Noter que ce test fait réussir la condition suivante
    # icmodule.instance_variable_set('@icetape_id', nil)
    # icmodule.data[:icetape_id] = nil
    # icetapes = icmodule.icetapes.split(' ')
    # icetapes << id
    # icetapes = icetapes.join(' ')
    # icmodule.instance_variable_set('@icetapes', icetapes)
    # # /TEST

    add_check '', 'Contenue par l’ic-module', contained_by_icmodule?
    unless contained_by_icmodule?
      add_error "Cette ic-étape n'est pas contenue par l'ic-module…"
      add_solution "add-etape-#{id}", "Ajouter cette étape à l'ic-module"
      add_self_to_icmodule
    end

    # # TEST
    # # Pour générer l'erreur de status à 0
    # @status = data[:status] = 0

    # # TEST
    # # Pour générer l'erreur de status à 1
    # @status = data[:status] = 1

    # En cas d'erreur, le template pour ajouter le watcher
    # Ne pas mettre :data, :triggered, :created_at, :updated_at, car
    # ce temp sert aussi à chercher les données
    temp_data = {user_id: icarien.id, objet:'ic_etape', objet_id:id, processus:nil}

    # L'étape courante doit avoir le bon watcher en fonction de son
    # état
    add_info 'State', status
    case status
    when 0
      add_error "Le status de l'étape ne devrait jamais valoir 0"
      add_solution 'status-1-icetape', "Passer le status de l'étape à 1"
    when 1
      # Un watcher pour remettre son travail doit exister
      err, solution = no_watcher_send_work?(temp_data.merge(processus:'send_work'))
      if err === nil
        add_check 'Watcher', "Un watcher pour remettre son travail existe", true
      else
        add_error err
        add_solution 'watcher-send-work', solution
      end
    else
      # Pour tous les autres cas, ce sont les documents de l'étape qu'il faut
      # checker

      # On commence par s'assurer qu'il y a des documents
      if documents.count === 0
        add_fatal_error "Aucun document pour cette étape. Ce n'est pas normal. Je dois renoncer."
        return
      end

      # On check chaque document
      idocuments.each { |did, idocument| idocument.check }

    end

  end


  # ---------------------------------------------------------------------
  #   Sous-méthode de check


  def no_watcher_send_work?(tempnew)
    cond = h2sql_condition(tempnew)
    dwatchers = site.db_execute('hot', "SELECT * FROM watchers WHERE #{cond} ORDER BY created_at ASC")
    res = traite_only_one_watchers(dwatchers, 'hot', 'watchers', tempnew)
    if res === nil
      return [nil, nil]
    elsif res === false # aucun watcher trouvé
      return ['Aucun watcher send-work trouvé.', "Créer un watcher send-work pour cette étape"]
    else # plusieurs watchers trouvés
      return ["Plusieurs watchers trouvés.", "Seul le watcher ##{res} doit être conservé."]
    end
  end

  # Retourne true si le démarrage de l'étape survient bien après le
  # démarrage du module.
  def start_after_start_module?
    started_at > icmodule.started_at
  end

  # Retourne true si l'icmodule contient bien cette étape
  def contained_by_icmodule?
    icmodule.icetape_id.to_i == id.to_i || icmodule.icetapes.split(' ').include?(id.to_s)
  end

  # ---------------------------------------------------------------------
  #   Méthodes de corrections

  def add_self_to_icmodule
    new_icetapes = []
    added = false
    icmodule.icetapes.split(' ').each do |eid|
      if eid.to_i > id
        new_icetapes << id
        added = true
      end
      new_icetapes << id
    end
    added || new_icetapes << id
    correct('modules','icmodules', icmodule.id, 'icetapes', new_icetapes.join(' '))
  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles utiles

  def exists?
    !data.nil?
  end

  # ---------------------------------------------------------------------
  # Propriétés utiles

  # Data de l'icetape dans la base de données
  def data_in_db
    @data ||= begin
      site.db_execute('modules',"SELECT * FROM icetapes WHERE id = #{id}")[0]
    end
  end
  alias :data :data_in_db

  def idocuments
    @idocuments ||= begin
      h = {};documents.each do |did|
        h.merge!(did.to_i => Admin::Checker::Document.new(self, did.to_i))
      end;h
    end
  end
  def icmodule_id
    @icmodule_id ||= data[:icmodule_id].to_i
  end
  def abs_etape_id
    @abs_etape_id ||= data[:abs_etape_id].to_i
  end
  def documents
    @documents ||= data[:documents].split(' ')
  end
  def status
    @status ||= data[:status].to_i
  end
  def started_at
    @started_at ||= data[:started_at]
  end
  def created_at
    @created_at ||= data[:created_at]
  end
  def updated_at
    @updated_at ||= data[:updated_at]
  end

end #/IcEtape
end #/Checker
end #/Admin
