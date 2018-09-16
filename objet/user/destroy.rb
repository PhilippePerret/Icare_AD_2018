# encoding: UTF-8
# require 'sqlite3'

class User

  RAISONS_DESTROY = [
    "Je n'ai plus le temps d'écrire",
    "Je n'ai plus rien à apprendre du BOA",
    "Ce site ne me plait pas du tout",
    "J'ai renoncé à l'écriture"
  ]

  # Procédure complète de destruction du compte de l'user
  # Note : Elle ne s'appelle pas `destroy` car elle serait directement
  # appelée par la route.
  def exec_destroy
    raise "Pirate !" if (self.id != site.current_route.objet_id) && !user.admin?
    dkill[:confirmation_destroy] == '1' || raise( "Opération impossible." )
    self.id != 1 || raise( 'Impossible de détruire Phil' )
    self.id != 3 || raise( 'Impossible de détruire Marion')

    # On conserve les données simplement pour la rédaction
    # des messages.
    @data_killed = {
      pseudo: self.pseudo.freeze,
      id:     self.id.freeze
    }

    # === DESTRUCTION ===
    proceed_destruction

    flash "Vous avez été détruit avec succès, #{@data_killed[:pseudo]}. Au regret de vous voir partir…"
    redirect_to :home
  rescue Exception => e
    debug e
    error e.message
    return false
  else
    return true
  end

  # Méthode qui procède vraiment à toutes les opérations
  # de destruction de l'auteur.
  def proceed_destruction
    unless user.id.nil? || user.id == 1

      # NON, on ne détruit plus l'user dans la base, sinon, ça crée plein
      # de problèmes. Au lieu de ça, on indique dans ses options qu'il a
      # été détruit.
      # dbtable_users.delete(user.id)

      opts = user.get(:options).ljust(26,'0')
      # debug "Anciennes options = #{opts.inspect}"

      # Indiquer qu'il est détruit
      opts[3] = '1'
      # Ne recevra plus aucun mail
      opts[4] = '9'
      # Mis en inactif si c'est un vrai icarien
      if opts[16].to_i & 1 > 0
        opts[16] = '5'
      end
      # Ne recevra jamais de mail
      opts[17] = '1'
      # Incontactable par les autres icares
      opts[19] = '8'
      # Incontactable par le reste du monde
      opts[23] = '8'
      # Aucun partage de l'historique
      opts[21] = '0'
      # Aucune notification si message
      opts[22] = '0'

      # debug "Nouvelles options : #{opts.inspect}"

      # On peut enregistrer ses nouvelles options
      user.set(options: opts)
      # On met aussi son mot crypté à rien pour qu'il
      # ne puisse plus s'identifier
      user.set(cpassword: 'x'*32)

    end
    (deconnexion unless user.admin?) rescue nil
    # remove # méthode générale qui détruit et la donnée dans la base
  end

  def dkill
    @dkill ||= param(:destroy) || Hash.new
  end

  # ---------------------------------------------------------------------
  #   Helper méthodes
  # ---------------------------------------------------------------------

  def self.menu_raison_supp_compte
    RAISONS_DESTROY.each_with_index.collect do |raison, iraison|
      raison.in_option(value: iraison)
    end.join('').in_select(name:'destroy[raison]', id:'destroy_raison')
  end
end

if param(:operation) == 'destroy_compte'
  # Pour qu'un administrateur puisse aussi détruire un user par
  # le biais de cette méthode, il ne faut pas prendre l'user
  # courant mais l'user défini dans la route.
  #
  # Une protection sérieuse est faite pour empêcher n'importe
  # qui de procéder à l'opération.
  User.get(site.current_route.objet_id).exec_destroy
end
