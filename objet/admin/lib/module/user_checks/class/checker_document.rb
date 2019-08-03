class Admin
class Checker
class Document

  require_relative '_module_messages'
  require_relative '_module_props'
  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

  attr_reader :icetape, :id

  def initialize icetape, id
    @id = id
    @icetape = icetape
  end

  # Check du document
  def check

    add_title "📃 Check du document ##{id} (#{original_name})"

    # TEST
    # Pour générer l'erreur suivante
    # user_id = 1

    # Le document doit être attribué au bon auteur
    ok = user_id === icarien.id
    success = "Le document est bien attribué à l'auteur ##{user_id}"
    failure = "Le document devrait être attribué à l'auteur ##{icarien.id}. il est attribué à ##{user_id}."
    add_check('Owner',ok ? success : failure, ok)
    unless ok
      add_solution("change-auteur-#{id}", "Il faut mettre l'auteur du document à ##{icarien.id}.")
      correct('modules','icdocuments',id, 'user_id', icarien.id)
    end

    # Le document doit être attribué au bon module
    # --------------------------------------------

    # TEST Pour générer l'erreur suivante
    # icmodule_id = 10000000

    ok = icmodule_id === icetape.icmodule_id
    success = "Le document appartient bien à l'ic-module ##{icetape.icmodule_id}"
    failure = "Le document devrait appartenir à l'ic-module ##{icetape.icmodule_id}. Il appartient à ##{icmodule_id}."
    add_check('Ic-module', ok ? success : failure, ok)
    unless ok
      add_solution("change-icmodule-#{id}", "Il faut mettre l'ic-module du document à ##{icetape.icmodule_id}.")
      correct('modules','icdocuments',id, 'icmodule_id', icetape.icmodule_id)
    end

    # Le document doit être attribué au bon module absolu
    # ---------------------------------------------------

    # TEST Pour générer l'erreur suivante
    # abs_module_id = 0.5

    ok = abs_module_id === icetape.icmodule.abs_module_id
    success = "Le document appartient bien au module absolu ##{abs_module_id}"
    failure = "Le document devrait appartenir au module absolu ##{icetape.icmodule.abs_module_id}. Il appartient à ##{abs_module_id}."
    add_check('Module absolu', ok ? success : failure, ok)
    unless ok
      add_solution("change-absmodule-#{id}", "Il faut mettre l'abs-module du document à ##{icetape.icmodule.abs_module_id}.")
      correct('modules','icdocuments',id, 'abs_module_id', icetape.icmodule.abs_module_id)
    end

    # Le document doit être attribué à la bonne étape relative
    # --------------------------------------------------------

    # TEST Pour générer l'erreur suivante
    # icetape_id = 0.5

    ok = icetape_id === icetape.id
    success = "Le document appartient bien à l'étape ##{icetape.id}"
    failure = "Le document devrait appartenir à l'étape ##{icetape.id}. Il appartient à ##{icetape_id}"
    add_check('Ic-étape', ok ? success : failure, ok)
    unless ok
      add_solution("change-etape-id-#{id}", "Il faut mettre l'ic-etape du document à ##{icetape.id}.")
      correct('modules','icdocuments',id, 'icetape_id', icetape.id)
    end

    # TEST Pour générer l'erreur suivante
    # abs_etape_id = 0.2

    # Le document doit être attribué à la bonne étape absolue
    ok = abs_etape_id === icetape.abs_etape_id
    success = "Le document appartient bien à l'étape absolue ##{abs_etape_id}"
    failure = "Le document devrait appartenir à l'étape absolue ##{icetape.abs_etape_id}. Il appartient à ##{abs_etape_id}."
    add_check('Étape absolue', ok ? success : failure, ok)
    unless ok
      add_solution("change-absetape-#{id}", "Il faut mettre l'abs-module du document à ##{icetape.abs_etape_id}.")
      correct('modules','icdocuments',id, 'abs_etape_id', icetape.abs_etape_id)
    end

    # Check watcher by etape status
    check_watcher_by_etape_status

  end

  def check_watcher_by_etape_status
    # En fonction du status de l'étape, on doit trouver un watcher particulier
    case icetape.status
    when 2 then check_when_sended_but_not_adminloaded
    when 3 then check_when_adminloaded
    when 4 then check_when_send_comments
    when 5 then check_when_userloaded
    when 6 then check_if_watcher_define_sharing
    end
  end

  def check_when_sended_but_not_adminloaded
    check_watcher('admin_download')
  end

  def check_when_adminloaded
    check_watcher('upload_comments')
  end

  def check_when_send_comments
    check_watcher('user_download_comments')
  end

  def check_when_userloaded
    check_watcher('define_partage')
  end

  def check_if_watcher_define_sharing
    check_watcher('depot_qdd')
  end

  def check_watcher process
    tempnew = temp_watcher_processus(process)
    cond = h2sql_condition(tempnew)
    dwatchers = site.db_execute('hot', "SELECT * FROM watchers WHERE #{cond} ORDER BY created_at ASC")
    traite_only_one_watchers(dwatchers,'hot', 'watchers', tempnew)
    # Il faut voir si le document ne possède pas d'autres watchers qui trainent
    # TODO
    cond = h2sql_condition({objet:'ic_document', objet_id:id})
    cond += " AND processus != \"#{process}\""
    dwatchers = site.db_execute('hot', "SELECT * FROM watchers WHERE #{cond} ORDER BY created_at ASC")

    # TEST Pour générer l'erreur suivante
    dwatchers = [{id:12},{id:14}]
    # /TEST

    # On propose de supprimer les watchers incohérents
    if dwatchers.count > 0
      add_error("Le document contient des watchers incohérents")
      dwatchers.each do |hwatcher|
        correct('hot','watchers', hwatcher[:id],'DELETE')
      end
      add_solution("kill-watchers-#{id}", "Détruire les watchers incohérents (#{dwatchers.collect{|h|h[:id]}.join(', ')})")
    end
  end

  def temp_watcher_processus process
    {user_id:icarien.id, objet:'ic_document', objet_id:id, processus:process}
  end

  # ---------------------------------------------------------------------
  #   Propriétés fixes

  def data
    @data ||= site.db_execute('modules',"SELECT * FROM icdocuments WHERE id = #{id}")[0]
  end

  def user_id
    @user_id ||= data[:user_id]
  end
  def abs_etape_id
    @abs_etape_id ||= data[:abs_etape_id]
  end
  def icetape_id
    @icetape_id ||= data[:icetape_id]
  end
  def abs_module_id
    @abs_module_id ||= data[:abs_module_id]
  end
  def icmodule_id
    @icmodule_id ||= data[:icmodule_id]
  end
  def original_name
    @original_name ||= data[:original_name]
  end

end #/Document
end #/Checker
end #/Admin
