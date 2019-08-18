# encoding: UTF-8
=begin

  Affichage de la liste des icariens (pour n'importe qui)

  QUESTION :
    Où la faire apparaitre ?

=end



# Méthode qui construit les listes des icariens
# et RETURN la liste de type +utype+
#
def get_icariens_of_type utype
  @tous_les_icariens ||= begin
    h = {actifs: Array.new, inactifs: Array.new, en_attente: Array.new, admin: Array.new}
    drequest = {colonnes: []}
    dbtable_users.select(drequest).collect do |huser|
      u = User.new(huser[:id])
      ktype =
        case true
        when u.admin? then :admin
        when u.actif? then :actifs
        when u.recu?  then :inactifs
        else :en_attente
        end

      # On ajoute cet icarien/ne à la liste
      h[ktype] << u
    end
    h
  end
  return @tous_les_icariens[utype]
end

def get_all_modules_of user_id
  @all_modules ||= begin
    site.require_objet 'ic_module'
    h = Hash.new
    dbtable_icmodules.select(colonnes:[:user_id]).each do |hmod|
      uid = hmod[:user_id]
      h.key?(uid) || h.merge!(uid => Array.new)
      h[uid] << IcModule.new(hmod[:id])
    end
    h
  end
  return @all_modules[user_id]
end

# = main =
#
# Méthode principale qui constuit la liste des icariens du type
# +utype+ qui peut être :actifs, :inactifs et :non_recus
#
def liste_icariens utype
  get_icariens_of_type(utype).collect do |u|
    u.as_card
  end.join.in_ul(class: 'icariens')
end

# Les méthodes d'helper pour afficher la liste
class User

  # La méthode principale pour afficher l'icarien
  def as_card
    (
      picto_avatar.in_span(class: 'avatar') +
      (
        pseudo.capitalize.in_span(class: 'pseudo') +
        date_inscription.in_span(class: 'from') +
        le_module_courant.in_span(class: 'module_courant') +
        liste_autres_modules.in_span(class: 'autres_modules') +
        boite_contact
      ).in_div(style: 'margin-left: 3em')
    ).in_li(class: 'icarien')
  end


  def picto_avatar
    @picto_avatar ||= begin
      path = "icones/#{femme? ? 'femme' : 'homme'}.png"
      image(path, class: 'avatar')
    end
  end

  def date_inscription
    @date_inscription ||= begin
      fct =
        if admin?
          "administra#{f_trice}"
        else
          "icarien#{f_ne}"
        end
      " est #{fct} depuis le #{created_at.as_human_date}. "
    end
  end

  def le_module_courant
    admin? && (return '')
    icmodule_id != nil || (return '')
    icmodule.started_at != nil || (return '')
    date_start_module = icmodule.started_at.as_human_date
    "#{f_elle.capitalize} suit le module <strong>#{lien_module_app(icmodule.abs_module)}</strong> depuis le #{date_start_module}. "
  rescue Exception => e
    debug e
    send_error_to_admin(
      exception: e,
      from: "liste des icariens, avec #{self.pseudo} (##{self.id})"
    )
    ''
  end
  def liste_autres_modules
    admin? && (return '')
    modules = get_all_modules_of( self.id )
    modules != nil || (return '')
    autres_modules =
      if icmodule_id.nil?
        modules
      else
        modules.reject{ |m| m.id == icmodule_id}
      end
    autres_modules.count > 0 || (return '')
    s = autres_modules.count > 1 ? 's' : ''
    autres_modules = autres_modules.collect do |m|
      add_project = m.project_name ? " pour son projet “#{m.project_name}”" : ''
      lien_module_app(m.abs_module).in_span(class: 'bold') + add_project
    end.pretty_join
    auparavant = icmodule_id.nil? ? '' : ' auparavant'
    "#{pseudo.capitalize} a suivi#{auparavant} le#{s} module#{s} #{autres_modules}."
  end

  # Partie de la carte qui permet de prendre contact avec l'icarien en
  # fonction de ses préférences. Il y a deux destinataires possibles : un
  # icarien ou un simple visiteur et deux moyens de contacts : le mail ou
  # le message sur bureau
  def boite_contact
    liens_messages = Array.new
    if user.icarien?
      if [0,1].include?(self.pref_type_contact)
        liens_messages << lien_message_mail
      end
      if [0,2].include?(self.pref_type_contact)
        liens_messages << lien_message_frigo
      end
    end
    if [0,1].include?(self.pref_type_contact_world)
      liens_messages << lien_message_mail
    end
    if [0,2].include?(self.pref_type_contact_world)
      liens_messages << lien_message_frigo
    end
    liens_messages = liens_messages.uniq
    liens_messages.count > 0 || (return '')
    liens_messages.join(' ').in_div(class: 'contacts')
  end
  # /boite_contact
  def lien_message_frigo
    'message bureau'.in_a(href: "bureau/#{id}/frigo", target: :new)
  end
  def lien_message_mail
    'mail'.in_a(href: "site/contact?to=#{id}", target: :new)
  end
  # Retourne un lien pour afficher le nom du module, avec un lien
  # conduisant à sa présentation.
  def lien_module_app(mod_app)
    mod_app.name.downcase.in_a(href:"abs_module/#{mod_app.id}/show", target: :new)
  end
end
