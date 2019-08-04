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

    add_title "📄 Check du document ##{id} (#{original_name})"

    # TEST
    # Pour générer l'erreur suivante
    # user_id = 1

    # Le document doit être attribué au bon auteur
    ok = user_id === icarien.id
    success = "Le document est bien attribué à l'auteur ##{user_id}"
    failure = "Le document devrait être attribué à l'auteur ##{icarien.id}. il est attribué à ##{user_id}."
    add_check('Owner',ok ? success : failure, ok)
    unless ok
      sol_msg = "Il faut mettre l'auteur du document à ##{icarien.id}."
      correct("change-auteur-#{id}", sol_msg, 'modules','icdocuments',id, 'user_id', icarien.id)
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
      sol_msg = "Il faut mettre l'ic-module du document à ##{icetape.icmodule_id}."
      correct("change-icmodule-#{id}", sol_msg, 'modules','icdocuments',id, 'icmodule_id', icetape.icmodule_id)
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
      sol_msg = "Il faut mettre l'abs-module du document à ##{icetape.icmodule.abs_module_id}."
      correct("change-absmodule-#{id}", sol_msg, 'modules','icdocuments',id, 'abs_module_id', icetape.icmodule.abs_module_id)
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
      sol_msg = "Il faut mettre l'ic-etape du document à ##{icetape.id}."
      correct("change-etape-id-#{id}", sol_msg, 'modules','icdocuments',id, 'icetape_id', icetape.id)
    end

    # TEST Pour générer l'erreur suivante
    # abs_etape_id = 0.2

    # Le document doit être attribué à la bonne étape absolue
    ok = abs_etape_id === icetape.abs_etape_id
    success = "Le document appartient bien à l'étape absolue ##{abs_etape_id}"
    failure = "Le document devrait appartenir à l'étape absolue ##{icetape.abs_etape_id}. Il appartient à ##{abs_etape_id}."
    add_check('Étape absolue', ok ? success : failure, ok)
    unless ok
      sol_msg = "Il faut mettre l'abs-module du document à ##{icetape.abs_etape_id}."
      correct("change-absetape-#{id}", sol_msg, 'modules','icdocuments',id, 'abs_etape_id', icetape.abs_etape_id)
    end

    # Le document doit avec des temps cohérents
    # -----------------------------------------
    check_document_times

    # Check des options du document
    # -----------------------------
    check_options

    # Check watcher by etape status
    check_watcher_by_etape_status

  end

  # Méthode qui s'assure que les options sont cohérentes
  #
  # cf. objet/ic_document/lib/required/instance/options.rb
  def check_options
    options
    @options = @options.ljust(16,'0')
    new_options = "#{options}"

    errs = []

    # # TEST pour générer l'erreur suivante
    # @options[0] = "0"

    okb0 = options[0] == "1"
    unless okb0
      errs << "l'original devrait être marqué existant"
      new_options[0] = "1"
    end

    # TEST Pour générer le test suivant
    # @options[1] = "1"

    okb1 = options[1] == "0"
    unless okb1
      errs << "le partage ne devrait pas être défini"
      new_options[1] = "0"
    end

    # Bit de téléchargement du fichier original par l'administrateur
    # Il dépend du status de l'étape

    # TEST Pour générer le test suivant
    # @options[2] = icetape.status >= 2 ? "0" : "1"

    okb2 = options[2] == icetape.status >= 2 ? "1" : "0"
    unless okb2
      errs << "le document original devrait être marqué #{icetape.status >= 2 ? "" : "non "}chargé"
      new_options[2] = icetape.status >= 2 ? "1" : "0"
    end

    # Bit de dépôt du fichier original sur le QDD
    # Il dépend du status de l'étape

    # TEST Pour générer le test suivant
    # @options[3] = icetape.status >= 6 ? "0" : "1"

    okb3 = options[3] == icetape.status >= 6 ? "1" : "0"
    unless okb3
      errs << "le document original #{icetape.status >= 6 ? "devrait" : "ne devrait pas"} être déposé sur le QDD"
      new_options[3] = icetape.status >= 6 ? "1" : "0"
    end

    # Bit de définition du partage du fichier original
    # Il dépend du status de l'étape

    # TEST Pour générer le test suivant
    # @options[4] = icetape.status >= 7 ? "0" : "1"

    okb4 = options[4] == icetape.status >= 7 ? "1" : "0"
    unless okb4
      errs << "le partage de l'original #{icetape.status >= 7 ? "devrait" : "ne devrait pas"} être défini"
      new_options[4] = icetape.status >= 7 ? "1" : "0"
    end


    # ---------------------------------------------------------------------
    #   Document commentaires

    # # TEST Pour générer l'erreur suivante
    # time_comments = time_original + 4.days
    # @options[8] = "0"
    # # Ou
    # time_comments = nil
    # @options[8] = "1"

    okb8 = options[8] == time_comments ? "1" : "0"
    unless okb8
      errs << "Les commentaires devrait être marqués #{time_comments ? 'existants' : 'inexistant'}"
      new_options[8] = time_comments ? "1" : "0"
    end

    # # TEST Pour générer le test suivant
    # @options[9] = "1"

    okb9 = options[9] == "0"
    unless okb9
      errs << "le partage ne devrait pas être défini"
      new_options[9] = "0"
    end

    # Bit de téléchargement du fichier commentaires par l'icarien
    # Il dépend du status de l'étape

    # # TEST Pour générer le test suivant
    # @options[10] = icetape.status >= 5 ? "0" : "1"

    okb10 = options[10] == icetape.status >= 5 ? "1" : "0"
    unless okb10
      errs << "les commentaires devraient être marqués #{icetape.status >= 5 ? "" : "non "}chargés par l'user"
      new_options[10] = icetape.status >= 5 ? "1" : "0"
    end

    # Bit de dépôt du fichier original sur le QDD
    # Il dépend du status de l'étape

    # # TEST Pour générer le test suivant
    # @options[11] = icetape.status >= 6 ? "0" : "1"

    okb11 = options[11] == icetape.status >= 6 ? "1" : "0"
    unless okb11
      errs << "le doc des commentaires #{icetape.status >= 6 ? "devrait" : "ne devrait pas"} être déposé sur le QDD"
      new_options[11] = icetape.status >= 6 ? "1" : "0"
    end

    # Bit de définition du partage du fichier original
    # Il dépend du status de l'étape

    # # TEST Pour générer le test suivant
    # @options[12] = icetape.status >= 7 ? "0" : "1"

    okb12 = options[12] == icetape.status >= 7 ? "1" : "0"
    unless okb12
      errs << "le partage des commentaires #{icetape.status >= 7 ? "devrait" : "ne devrait pas"} être défini"
      new_options[12] = icetape.status >= 7 ? "1" : "0"
    end


    # ---------------------------------------------------------------------
    # Conclusion

    success = "Les options sont cohérentes"
    failure = "Les options doivent être réparées : #{errs.join(', ')}"
    ok = okb0 && okb1 && okb2 && okb3 && okb4 && okb8 && okb9 && okb10 && okb11 && okb12
    add_check('Options', ok ? success : failure, ok)
    unless ok
      sol_msg = "Réparer les options du document ##{id}"
      correct("options-d#{id}", sol_msg, 'modules','icdocuments',id,'options',new_options)
    end
  end

  # Méthode qui s'assure que les temps sont cohérents
  #
  # Note : pour le moment, on ne teste vraiment que l'étape courante, donc
  # pas vraiment tous les temps. On n'a pas la date de fin de l'étape, par
  # exemple, pour vérifier que le document n'a pas été remis après.
  def check_document_times

    errs = []

    # TEST Pour générer l'erreur suivante
    # time_original = icetape.started_at - 2.days

    ok_time_original = time_original > icetape.started_at
    errs << "date de remise de l'original" unless ok_time_original

    # TEST Pour générer l'erreur suivante
    # created_at = icetape.started_at - 2.days

    ok_created_at = created_at > icetape.started_at
    errs << "created_at" unless ok_created_at

    # TEST Pour générer l'erreur suivante
    # time_comments = time_original - 2.days

    ok_time_comments = time_comments.nil? || (time_comments > time_original)
    errs << "date de remise des commentaires" unless ok_time_comments

    # TEST Pour générer l'erreur suivante
    # expected_comments = created_at - 2.days

    ok_expected_comments = expected_comments > time_original + 1.day
    errs << "date espérée de la remise des commentaires"

    ok = ok_time_original && ok_expected_comments && ok_time_comments && ok_created_at
    success = "Les temps du document sont cohérents"
    failure = "Les temps suivants doivent être réparés : #{errs.join(', ')}."
    add_check('Temps et dates', ok ? success : failure, ok)

    # Les corrections proposés
    unless ok_created_at
      newtime = icetape.started_at + 4.days
      sol_msg = "Mettre le created_at au #{fdate(newtime)}"
      correct("change-ctime-#{id}", sol_msg, 'modules','icdocuments', id, 'created_at', newtime)
    end
    unless ok_time_original
      newtime = icetape.started_at + 4.days
      sol_msg = "Mettre la date de l'original au #{fdate(newtime)}"
      correct("change-oritime-#{id}", sol_msg, 'modules','icdocuments', id, 'time_original', newtime)
    end
    unless ok_expected_comments
      newtime = time_original + 4.days
      sol_msg = "Mettre la date de remise espérée des commentaires au #{fdate(newtime)}"
      correct("exptime-#{id}", sol_msg, 'modules','icdocuments',id,'expected_comments',newtime)
    end
    unless ok_time_comments
      newtime = time_original + 2.days
      sol_msg = "Mettre la date des commentaires au #{fdate(newtime)}"
      correct("change-comtime-#{id}", sol_msg, 'modules','icdocuments', id, 'time_comments', newtime)
    end

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
      sol_msg = "Détruire les watchers incohérents (#{dwatchers.collect{|h|h[:id]}.join(', ')})"
      dwatchers.each do |hwatcher|
        correct("kill-watcher-#{hwatcher[:id]}-doc-#{id}", sol_msg, 'hot','watchers', hwatcher[:id],'DELETE')
      end
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
  def options
    @options ||= data[:options]
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
  def time_original
    @time_original ||= data[:time_original]
  end
  def expected_comments
    @expected_comments ||= data[:expected_comments]
  end
  def time_comments
    @time_comments ||= data[:time_comments]
  end
  def created_at
    @created_at ||= data[:created_at]
  end
  def updated_at
    @updated_at ||= data[:updated_at]
  end

end #/Document
end #/Checker
end #/Admin
