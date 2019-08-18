# encoding: UTF-8
raise_unless_admin
class App

  def _visit_as user_id, options = nil
    options ||= Hash.new
    user_id.instance_of?(Integer) || user_id = user_id.id

    # Un nombre aléatoire
    alea = begin
      require 'securerandom'
      SecureRandom.hex
    end

    # = Fabrication du fichier ADM =
    path_adm = _adm_folder + alea
    data_adm = {
      session_id: app.session.session_id,
      ip:         user.ip,
      user_id:    user_id,
      alea:       alea,
      admin_id:   user.id
    }
    path_adm.write Marshal.dump(data_adm)

    # On met le nombre aléatoire en variable session, dans 'admin_visit_as'
    # variable session qui détermine pour le programme, au rechargement de
    # la page, que c'est l'administrateur qui visite comme un user.
    app.session['admin_visit_as'] = alea

  end
end
