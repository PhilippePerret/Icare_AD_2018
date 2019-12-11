# encoding: UTF-8
=begin

  La classe appelante doit définir @sync qui est l'instance
  `sync` principale. Donc :
      class Sync
        def dosync
          NouvelleClasse.instance.synchronize(self) # <= ici le self
        end
        ...
        class NouvelleClasse
          include Singleton
          include CommonSyncMethods

          synchronize(s) # on reçoit sync
            @sync = s # on définit @sync pour les méthodes d'ici
            ...
          end
        end
      end

  MÉTHODES DE FICHIERS
  --------------------

  sync_files local_folder, distant_folder

    Synchronise les fichiers des dossiers local_folder et
    distant_folder, en synchronisant le dossier distant sur
    le dossier local (mais pas l'inverse)

    Le module appelant doit utiliser `@nombre_synchronisations`
    pour compter le nombre d'actualisation. Dans le cas
    contraire, la méthode retourne le nombre de fichiers
    détruits ou uploadés.

    La méthode incrémente @nombre_synchronisations et inscrit
    dans le rapport (report) et le suivi tout ce qu'il faut
    savoir.

  get_distant_files distant_folder

    Retourne la liste des fichiers du dossier distant `distant_folder`
    C'est un Hash avec en clé le chemin relatif depuis ce dossier et
    en valeur le temps de dernière modification du fichier.

  get_local_files local_folder

    Idem que ci-dessus mais pour un dossier local

  upload_file localpath, distantpath

    Upload le fichier `localpath` vers le fichier `distantpath`
    en utilisant la définition de `serveur_ssh` (qui doit donc être définie)

  download_file distantpath, localpath

    Download le fichier distant `distantpath` vers le fichier local `localpath`
    en utilisant la définition de serveur_path (qui doit donc être définie)

  MÉTHODES MYSQL
  --------------

    reset

        Pour tout resetter lorsque l'on change de nom de
        table par exemple dans une synchronisation.

    Dans la classe utilisant ces méthodes il faut impérativement
    définir `db_suffix` (suffixe de la base de données) et
    `table_name` (nom de la table dans la base).

    Les méthodes `dis_rows` et `loc_rows` renvoient alors
    toutes les rangées des deux tables.

    Un premier argument optionnel (Hash) permet de définir
    plusieurs choses :

      options:{

        main_key:     Par défaut, la clé principale utilisée pour le
                      hash des rangées renvoyées est :id, mais on peut
                      en définir une autre avec cette valeur.
        Toutes les autres propriétés serviront de premier argument
        à `select`. Donc on peut trouver :where, :colonnes, :order, etc.
      }
=end
module CommonSyncMethods

  # Peut être surclassé par les méthodes de la
  # classe chargeant le module.
  attr_reader :table_name
  # Peut-être surclassé par les méthodes de la
  # classe chargeant le module
  attr_reader :db_suffix

  # Définit le nom de la table de la base de données mais
  # surtout reset tout pour pouvoir rafraichir toutes les
  # informations courantes.
  def table_name= valeur
    @table_name = valeur
    reset
  end


  # Adresse du serveur SSH sous la forme "<user>@<adresse ssh>"
  # Note : Défini dans './objet/site/data_synchro.rb'
  def serveur_ssh
    @serveur_ssh ||= begin
      require './objet/site/data_synchro.rb'
      Synchro::new().serveur_ssh
    end
  end

  def reset
    db_reset
  end

  def suivi mess  ; @sync.suivi   << "    #{mess}"  end
  def report mess ; @sync.report  << "    #{mess}"  end
  def error mess
    @sync.errors  << mess
    false
  end


  # ---------------------------------------------------------------------
  #   MÉTHODES FICHIERS
  # ---------------------------------------------------------------------

  # Synchronise le dossier +dis_folder+ avec le dossier
  # +loc_folder+ (seulement dans ce sens).
  #
  # La méthode retourne le nombre de synchronisations
  # opérées, i.e. le nombre de fichiers détruits dans
  # dis_folder et le nombre d'uploads.
  #
  def sync_files loc_folder, dis_folder
    @nombre_synchronisations ||= 0

    loc_files = get_local_files(loc_folder)
    dis_files = get_distant_files(dis_folder)
    report "  Nombre fichiers locaux   : #{loc_files.count}"
    report "  Nombre fichiers distants : #{dis_files.count}"

    loc_files.each do |loc_path, loc_mtime|
      dis_mtime = dis_files.delete(loc_path)

      if dis_mtime.nil? || loc_mtime > dis_mtime
        if dis_mtime.nil?
          suivi "Le fichier #{loc_path} n'existe pas en online."
          report "  * Création du fichier DISTANT #{loc_path}…"
        elsif loc_mtime > dis_mtime
          suivi "Le fichier LOCAL #{loc_path} est plus jeune"
          report "  * Actualisation du fichier DISTANT #{loc_path}…"
        end

        # ============ SYNCHRONISATION ===============
        loc_fullpath = File.join(loc_folder, loc_path)
        dis_fullpath = File.join(dis_folder, loc_path)
        upload_file(loc_fullpath, dis_fullpath)
        # ============================================

        report "    = OK"
        @nombre_synchronisations += 1
      elsif dis_mtime > loc_mtime
        suivi "Bizarre, le fichier distant #{loc_path} est plus jeune que le fichier local (local: #{loc_mtime.inspect} / distant: #{dis_mtime.inspect})…"
      else
        suivi "Fichier #{loc_path} OK"
      end
    end

    # Les fichiers distants qui n'existent pas en local doivent
    # être détruits.
    if dis_files.count > 0
      report "  Nombre de fichiers DISTANTS à détruire : #{dis_files.count} "
      dis_files.each do |relpath, ctime|
        # On met une protection, au cas où
        unless relpath.nil_if_empty.nil? || relpath == '/'
          dis_fullpath = "#{dis_folder}/#{relpath}"
          rs = `ssh #{serveur_ssh} 'rm #{dis_fullpath}'`
          report "= Fichier #{relpath} DISTANT détruit avec succès"
        end
      end
    else
      report "Aucun fichiers distants à détruire."
    end

    return @nombre_synchronisations
  end

  # Méthode qui récupère les données des fichiers online.
  # C'est simplement un Hash contenant en clé le path du fichier
  # distant et en valeur sa date de modification.
  def get_distant_files infolder
    code_ssh = <<-SSH
res = {error: nil, files: nil}
begin
  h_files = {}
  main_folder = '#{infolder}'
  Dir[main_folder + '/**/*.*'].collect do |pany|
    relpath = pany.sub(/^\#{Regexp::escape main_folder}\\//,'')
    h_files.merge!( relpath => File.stat(pany).mtime.to_i )
  end
  res[:files] = h_files
rescue Exception => e
  res[:error] = e.message
end
STDOUT.write Marshal::dump(res)
    SSH
    rs = `ssh #{serveur_ssh} "ruby -e \\"#{code_ssh}\\""`
    if rs == ''
      raise "Impossible d'obtenir la liste des fichiers distants : retour SSH vide…"
    else
      rs = Marshal.load(rs)
      if rs[:error].nil?
        rs[:files]
      else
        raise "Impossible d'obtenir la liste des fichiers distants : #{rs[:error]}"
      end
    end
  end

  def get_local_files main_folder
    h_files = {}
    Dir[main_folder + '/**/*.*'].collect do |pany|
      relpath = pany.sub(/^#{main_folder}\//,'')
      h_files.merge!( relpath => File.stat(pany).mtime.to_i )
    end
    h_files
  end

  def upload_file locpath, dispath
    File.exist?(locpath) || raise("Le fichier local `#{locpath}` est introuvable, impossible de l'uploader…")
    dis_folder = File.dirname(dispath)
    cmd_mdir = "ssh #{serveur_ssh} mkdir -p #{dis_folder}"
    cmd_scp = "scp -pv '#{locpath}' #{serveur_ssh}:#{dispath}"
    `#{cmd_scp}`
  end

  def download_file dispath, locpath
    loc_folder = File.dirname(locpath)
    `mkdir -p #{loc_folder}`
    cmd_scp = "scp -pv #{serveur_ssh}:#{dispath} '#{locpath}'"
    `#{cmd_scp}`
  end

  # ---------------------------------------------------------------------
  #   MÉTHODES BASES DE DONNÉES
  # ---------------------------------------------------------------------

  # Permet de réinitialiser toutes les propriétés
  # d'instance concernant les bases de données, pour par exemple
  # changer de table.
  def db_reset
    @dis_rows   = nil
    @loc_rows   = nil
    @loc_table  = nil
    @dis_table  = nil
  end
  # Rangées dans la table distante
  # cf. plus haut pour options
  def dis_rows options = nil
    @dis_rows ||= rows(dis_table, options)
  end
  # Rangées dans la table locale
  # cf. plus haut pour options
  def loc_rows options = nil
    @loc_rows ||= rows(loc_table, options)
  end

  # Toutes les rangées de la table +table+, en hash avec
  # en clé l'identifiant.
  # cf. plus haut pour options
  def rows( table, options = nil )
    options ||= Hash.new
    main_key = options.delete(:main_key) || :id
    # Si la clé principale n'est pas :id, il faut ajouter la
    # main-key à la liste des colonnes si cette liste est définie
    main_key == :id || begin
      if options.key?(:colonnes)
        options[:colonnes] << main_key
        options[:colonnes] = options[:colonnes].uniq
      end
    end
    h = {}
    rs =
      if options.empty?
        table.select
      else
        table.select(options)
      end
    rs.each {|r| h.merge! r[main_key] => r }
    h
  end

  # Table locale
  def loc_table
    @loc_table ||= site.dbm_table(db_suffix, table_name, online = false)
  end
  # Table distante
  def dis_table
    @dis_table ||= site.dbm_table(db_suffix, table_name, online = true)
  end

end
