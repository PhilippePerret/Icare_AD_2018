# encoding: UTF-8
class App

  def visit_as user_id, options = nil
    site.require_module 'visit_as'
    _visit_as user_id, options
  end

  # Retourne true si c'est une "visite de l'administrateur comme…"
  # Quand l'administrateur prend l'identité d'un icarien pour
  # visiter le site, sans identification nécessaire.
  def visit_as?
    @is_visit_as === nil && begin
      if app.session['admin_visit_as'] != nil
        path_adm = _adm_folder + app.session['admin_visit_as']
        path_adm.exist? || (raise 'file')
        dva = Marshal.load(path_adm.read)
        app.session.session_id == dva[:session_id] || (raise 'session_id')
        user.ip == dva[:ip] || (raise 'ip')
        @is_visit_as = true
      else
        @is_visit_as = false
      end
    end
  rescue Exception => e
    debug "Donnée divergente pour `visit_as` : #{e.message}"
    debug e
    @is_visit_as = false
    raise "La piraterie est une activité néfaste."
  else
    return @is_visit_as
  end

  # Méthode appelée par le préambule pour voir si c'est une visite
  # de l'administrateur en tant qu'autre icarien.
  def check_visit_as_user
    visit_as? || return
    path_adm = _adm_folder + app.session['admin_visit_as']
    dva = Marshal.load(path_adm.read)
    user_id = dva[:user_id]
    # On s'autologin en tant que cet icarien
    u = User.new(user_id)
    u.autologin
  end

  def stop_visit_as
    app.session['admin_visit_as'] != nil || return
    path_adm = _adm_folder + app.session['admin_visit_as']
    path_adm.exist? || return
    dva = Marshal.load(path_adm.read)
    path_adm.remove
    app.session['admin_visit_as'] = nil
    u = User.new(dva[:admin_id])
    u.autologin
    flash "#{u.pseudo}, vous visitez à nouveau comme administrateur."
    redirect_to 'bureau/home'
  end

  # Pour envoyer une requête CURL en tant qu'administrateur, sans
  # se connecter
  def curl_as_admin url, options = nil
    options ||= Hash.new
    curl_as_user(url, options.merge(user_id: 1))
  end

  # Cf. RefBook > Admin_sans_identification.md
  def curl_as_user url, options = nil
    app.benchmark('-> App#curl_as_user')

    # Mettre à true pour débugger profondément cette méthode.
    # Ça enregistre tous les informations et les retours dans le fichier
    # `debug_curl_as_user.txt`
    debug_it_deep = false

    # Un nombre aléatoire
    alea = begin
      require 'securerandom'
      SecureRandom.hex
    end

    user_id   = options.delete(:user_id) || options.delete(:user).id
    is_online = !!(options.delete(:online) || options.delete(:distant))

    # Fabrication du fichier ADM
    path_adm = _adm_folder + alea
    path_adm.write app.session.session_id

    if debug_it_deep
      mess_pour_voir = Array.new
      mess_pour_voir << "\n\n=== #{Time.now} ==="
    end

    data_curl = options || Hash.new
    data_curl.merge!(
      '_adm'  => alea,
      'sid'   => app.session.session_id,
      'uid'   => user_id
      )

    if debug_it_deep
      mess_pour_voir << "options   = #{options.inspect}"
      mess_pour_voir << "data_curl = #{data_curl.inspect}"
    end

    # Les données finales de la commande CURL
    data_curl = data_curl.collect do |k, v|
        case v
        when Hash
          v.collect do |sk, sv|
            "#{k}[#{sk}]=#{CGI.escape sv.to_s}"
          end.join('&')
        when Array then raise 'Impossible pour le moment de passer des arrays'
        else
          "#{k}=#{CGI.escape v.to_s}"
        end
    end.join('&')
    full_url  = "#{site.send(is_online ? :distant_url : :local_url)}/#{url}"
    cmd = "curl -v -X POST --data \"#{data_curl}\" \"#{full_url}\" 2>&1"

    mess_pour_voir << cmd if debug_it_deep

    if debug_it_deep
      File.open('./debug_curl_as_user.txt','a'){|f| f.write mess_pour_voir.join("\n-- ")}
    end

    # --user-agent \"#{curl_user_agent}\"
    # debug "CMD curl-as-user : #{cmd}"

    # Envoi de l'url par curl
    res = `#{cmd}`
    # debug "Retour CMD : #{res.inspect}"

    if debug_it_deep
      File.open('./debug_curl_as_user.txt','a'){|f| f.write "RETOUR CURL : #{res.inspect}"}
    end

    app.benchmark('<- App#curl_as_user')

    return res
  end
  #/curl_as_user

  def curl_user_agent
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_6_8) AppleWebKit/534.30 (KHTML, like Gecko) Chrome/12.0.742.112 Safari/534.30"
  end

  # Méthode appelée dans le préambule
  #
  # Elle n'est exécutée que si les paramètres définissent _adm (contrôlé
  # au début de la méthode)
  #
  def check_curl_as_user
    _adm    = param(:_adm)
    _adm != nil || return
    fpath   = _adm_folder + _adm
    if fpath.exist?
      if fpath.read == param(:sid)
        fpath.remove
        flash 'Autoconnexion user réussie.'
        debug "Autologin de #{param(:uid).to_i}"
        User.new(param(:uid).to_i).autologin
        return true
      else
        raise "Le numérod de session ne correspond pas."
      end
    else
      raise "le fichier #{fpath} n'existe pas ou plus."
    end
  rescue Exception => e
    debug "# ERROR Connection impossible par _adm : #{e.message}"
    debug e
    error 'Impossible de vous autologuer de cette façon.'
  end

  def _adm_folder
    @_adm_folder ||= site.folder_tmp + '_adm'
  end
end #/ App
