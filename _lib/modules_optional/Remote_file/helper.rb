# encoding: UTF-8
=begin

Méthodes d'helper pour la synchronisation (note : celle des fichiers
indépendants tels que les bases de données du scénodico, etc.)

@usage

    RFile::new("./path/to/file.db").block_synchro

=end
class RFile
  class << self
    attr_reader :iform
    def new_iform
      @iform ||= 0
      @iform += 1
    end
  end # << self

  attr_reader :options

  # +options+
  #   :action     L'action du formulaire en cas de désynchro. Par
  #               défaut, la route courante.
  #   :verbose    Si true, envoie un message même lorsque les deux
  #               fichier sont synchronisés.
  #   :buttons    Détermine les boutons à afficher.
  #               Par défaut, c'est le bouton "logique" qui est affiché
  #               c'est-à-dire celui correspondant à l'actualisation à
  #               faire. Mais avec :buttons, on peut forcer les choses
  #               :both   Les deux boutons sont affichés.
  #               :upload   Seulement le bouton d'upload (local -> distant)
  #               :download Seulement le bouton de download (distant -> local)
  #
  # Noter que ces options sont mises dans @options
  def bloc_synchro options = nil
    @options = options || Hash.new
    # Cette méthode sert en même temps à construire le bloc
    # de synchro et à traiter la synchro du fichier. C'est
    # l'opération (param(:operation)) qui indique la synchro
    # qu'il faut faire.
    # Peut-être que le serveur SSH et/ou le path du fichier distant
    # ont été modifiés par rapport aux données de base du fichier
    # data_synchro.rb comme c'est le cas pour le scénodico (scenodico.db)
    # et le filmodico (filmodico.db) qui doivent être aussi synchronisés
    # sur l'atelier Icare. Dans ces cas-là, le remote-file a dû être
    # redéfini par le fichier qui a créé l'instance et cette méthode,
    # en construisant le bloc de synchro, a mis dans des champs cachés
    # les valeurs du serveur SSH et du path du fichier distant, donc les
    # traite ici.
    # En d'autres termes, si la vue/méthode appelante modifie le serveur
    # SSH ainsi que le path du fichier distant, il n'y a rien à faire
    # puisque cette méthode mémorise ces valeurs dans des champs cachés
    # qui sont ré-utilisés ici.
    # Noter que param(:operation) est mis à nil en bas de la méthode
    # pour ne lancer qu'une seule synchro à la fois.
    case param(:operation)
    when 'synchro_upload_local_rfile_to_distant_file'
      rfile_path          = param(:synchro_rfile_path)
      rfile_serveur       = param(:synchro_serveur_ssh)
      rfile_distant_path  = param(:synchro_rfile_path_distant)
      autre_rfile = RFile::new( rfile_path )
      if rfile_serveur != serveur_ssh
        autre_rfile.instance_variable_set('@serveur_ssh', rfile_serveur)
        # debug "Serveur SSH modifié"
      end
      if rfile_distant_path != distant.path
        autre_rfile.distant.instance_variable_set('@path', rfile_distant_path)
        autre_rfile.distant.instance_variable_set('@path_no_dot', nil)
        # debug "Path du fichier distant modifié"
      end
      autre_rfile.upload
      return autre_rfile.message
    when 'synchro_download_distant_rfile_local_file'
      rfile_path = param(:synchro_rfile_path)
      autre_rfile = RFile::new( rfile_path )
      autre_rfile.distant.download
      return autre_rfile.message
    else
      # On poursuit
    end

    @options[:action] ||= route_courante

    verbose = !!@options[:verbose]
    return "" if synchronized? && !verbose

    update_required = nil
    c = ""
    # - Check existence des fichiers -
    if exist? == false && distant.exist? == false
      raise "Ni le fichier local #{path} ni le fichier distant n'existent, impossible de les synchroniser…"
    end
    if exist?
      c << "Le fichier <strong>local</strong> existe.".in_div.freeze
      c << "Dernière modification : #{mtime.as_human_date(true, true)}".in_div.freeze
    else
      update_required = :distant_to_local
      c << "Le fichier <span class='bold'>local</span> n'existe pas.".in_span(class:'warning').in_div
    end
    if distant.exist?
      c << "Le fichier <strong>distant</strong> existe.".in_div.freeze
      c << "Dernière modification : #{distant.mtime.as_human_date(true, true)}".in_div.freeze
    else
      update_required = :local_to_distant
      c << "Le fichier <span class='bold'>distant</span> n'existe pas.".in_span(class:'warning').in_div
    end

    # - Check de la date des fichiers s'ils existent tous les deux
    if update_required.nil?
      if mtime == distant.mtime
        return "" unless verbose
      elsif mtime > distant.mtime
        update_required = :local_to_distant
      else
        update_required = :distant_to_local
      end
    end

    # ---------------------------------------------------------------------

    btns = if options[:buttons].nil?
      case update_required
      when :local_to_distant
        upload_form
      when :distant_to_local
        download_form
      else
        return "" unless verbose
        "Les deux fichiers sont synchronisés."
      end
    else
      case options[:buttons]
      when :both
        upload_form + download_form
      when :upload
        upload_form
      when :download
        download_form
      end
    end

    c << btns.in_div(class:'right')

    # Il peut y avoir plusieurs champs de synchronisation, il faut
    # donc ré-initialiser cette valeur pour ne pas lancer la synchro
    # aussi sur eux. Mais noter que c'est un problème : la synchronisation
    # fonctionnera toujours du premier vers le dernier. Même lorsque l'on
    # voudra synchroniser le dernier avant le premier, c'est le premier
    # qui sera synchronisé. Donc l'ordre est particulièremnet important
    # s'il y a plusieurs synchros à faire.
    param(:operation => nil)

    return c
  end

  def upload_form
    synchro_form :upload
  end
  def download_form
    synchro_form :download
  end
  def synchro_form sens
    ope = case sens
    when :upload
      "synchro_upload_local_rfile_to_distant_file"
    when :download
      "synchro_download_distant_rfile_local_file"
    end
    form_id = "form_synchro_#{RFile::new_iform}"
    (
      ope.in_hidden(name:'operation', id:'operation') +
      path.in_hidden(name:'synchro_rfile_path', id:'synchro_rfile_path') +
      serveur_ssh.in_hidden(name:'synchro_serveur_ssh', id:'synchro_serveur_ssh') +
      distant.path.in_hidden(name:'synchro_rfile_path_distant', id:'synchro_rfile_path_distant') +
      image("pictos/#{sens}.png", class:'btn', onclick:"$('form##{form_id}').submit()")
    ).in_form(id:form_id, action:options[:action], class:'inline')
  end

end
