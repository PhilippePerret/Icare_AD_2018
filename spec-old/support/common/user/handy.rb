# encoding: UTF-8
=begin
Handy méthodes pour les user
=end

# alias def identify
def go_and_identify mail, password = nil
  mail, password =
    case mail
    when String then [mail, password]
    when Hash   then [mail[:mail], mail[:password]]
    else raise 'Format de mail incorrect pour une identification'
    end

  visit_home
  click_link('S\'identifier')
  expect(page).to have_css('form#form_user_login')
  within('form#form_user_login') do
    fill_in('login_mail', with: mail)
    fill_in('login_password', with: password)
    click_button('OK')
  end
end
alias :identify :go_and_identify

def identify_phil
  require './data/secret/data_phil'
  go_and_identify DATA_PHIL[:mail], DATA_PHIL[:password]
  _action "Phil s'identifie"
end
def identify_benoit
  require './data/secret/data_benoit'
  go_and_identify DATA_BENOIT[:mail], DATA_BENOIT[:password]
  _action "Benoit s'identifie"
end

# Retourne un pseudo aléatoire d'une longeur de 6 à 16 lettres
# à peu près
def random_pseudo
  # Longeur aléatoire
  len_pseudo = 5 + rand(3)
  # Première lettre
  pse = (65 + rand(26)).chr
  liste_voyelles = ['a','e', 'i', 'o', 'u', 'y', 'oi'].freeze
  nombre_voyelles = liste_voyelles.count
  # Lettres suivantes
  (len_pseudo/2).times do
    pse << liste_voyelles[rand(nombre_voyelles)]
    pse << (97 + rand(26)).chr
  end
  return pse
end
alias :get_random_pseudo :random_pseudo

# {User} Retourne une instance User prise au hasard sur le site
#
# +options+
#   :but    Array des IDs à ne pas utiliser
#   :with_program   Si true, l'auteur doit avoir un programme 1a1s
#   :with_forum_messages
#     Si true, il faut trouver un utilisateur qui a des messages sur
#     le forum.
#
def get_any_user options = nil

  options ||= Hash.new
  ids, where = nil, Array::new

  if options[:but] && !options[:but].empty?
    where << "id NOT IN (#{options[:but].join(', ')})"
  end

  where = if where.empty?
    nil
  else
    where.join(' AND ')
  end

  if ids.nil?
    ids = if where.nil?
      User.table.select(colonnes:[:id]).keys
    else
      User.table.select(where:where, colonnes:[:id]).keys
    end
  end

  raise "Impossible de trouver des users répondant aux conditions…" if ids.empty?

  uid = ids.shuffle.shuffle.first
  u = User.new(uid)
  expect(u).to be_instance_of(User)
  return u
end

def phil
  u = User.new(1)
  expect(u).to be_instance_of(User)
  expect(u).to be_admin
  return u
end

def benoit
  u = User.new(50)
  u.exist? || begin
    # Il faut recréer Benoit
    require 'digest/md5'
    require './data/secret/data_benoit'
    data_benoit = DATA_BENOIT
    password = data_benoit.delete(:password)
    data_benoit.merge!(
      options:      data_benoit.delete(:default_options),
      cpassword:    Digest::MD5.hexdigest("#{DATA_BENOIT[:password]}#{DATA_BENOIT[:mail]}#{DATA_BENOIT[:salt]}"),
      updated_at:   NOW,
      created_at:   NOW
    )
    dbtable_users.insert(data_benoit)
  end
  expect(u).to be_instance_of(User)
  return u
end

# Retourne un Hash de données d'utilisateur pour insertion par
# exemple dans la table User sans autre création.
# +options+
#   :mail_confirmed     Si true, le bit 3 sera mis à 1
#                       True par défaut
#
def data_for_new_user options = nil
  options ||= Hash.new
  require 'digest/md5'

  upseudo = options[:pseudo]    || random_pseudo
  umail   = options[:mail]      || "mail#{upseudo.downcase}@chez.com"
  upwd    = options[:password]  || "motdepasse"
  options.key?(:mail_confirmed) || options.merge!(mail_confirmed: true)

  cpwd = Digest::MD5.hexdigest("#{upwd}#{umail}")
  {
    pseudo:     upseudo,
    patronyme:  "#{upseudo}",
    mail:       umail,
    cpassword:  cpwd,
    sexe:       options[:sexe] || ['H','F'][rand(2)],
    salt:       '',
    options:    options[:options] || "00#{options[:mail_confirmed] ? '1' : '0'}",
    created_at: options[:created_at] || (Time.now.to_i - 1.day),
    updated_at: options[:created_at] || (Time.now.to_i - 1.day)
  }
end

# Retourne des données au hasard mais valides pour un
# user. Le hash retourné contient toutes les données
# utiles pour le formulaire d'inscription.
def random_user_data mail = nil, password = nil
  now       = Time.now.to_i
  sexe      = ["H","F"][rand(2)]
  hsexe     = {'H' => 'un homme', 'F' => 'une femme'}[sexe]
  prenom    = UserSpec.random_prenom(sexe)
  salt      = "dubonsel"
  mail      ||= "mail#{sexe}#{now}@chez.moi"
  password  ||= "unmotdepasse"
  cpassword = Digest::MD5.hexdigest("#{password}#{mail}#{salt}")

  {
    pseudo:     "#{prenom.normalized}#{sexe}",
    patronyme:  "#{prenom} Patro #{sexe} N#{now}",
    mail:       mail,
    sexe:       sexe,
    hsexe:      hsexe,
    options:    "001000000000000000",
    salt:       salt,
    password:   password,
    cpassword:  cpassword
  }
end

# +options+
#
#   :unanunscript   Si true, l'inscrit au programme
#   :subscriber     Si true, crée un abonné
#   :current        Si true, le met en user courant
#
#   Toutes les autres propriétés servent à décrire les
#   données de l'user, qui seront enregistrées dans la
#   table
def create_user options = nil
  require 'digest/md5'
  now = Time.now.to_i
  options ||= Hash.new

  # Retirer les valeurs qui ne doivent pas être enregistrées
  mettre_courant = options.delete(:current) || programme_1a1s

  druser = random_user_data

  options[:sexe]        ||= druser[:sexe]
  options[:pseudo]      ||= druser[:pseudo]
  options[:patronyme]   ||= druser[:patronyme]
  options[:mail]        ||= druser[:mail]
  options[:options]     ||= druser[:options]
  options[:session_id] = app.session.session_id unless options.key?(:session_id)
  options[:created_at]  ||= now
  options[:updated_at]  ||= now

  pwd = options.delete(:password) || druser[:password]
  options[:salt]        ||= druser[:salt]
  cpwd = Digest::MD5.hexdigest("#{pwd}#{options[:mail]}#{options[:salt]}")
  options[:cpassword] = cpwd


  @id = User.table_users.insert(options)
  new_user = User.get(@id)
  # debug "ID du nouvel user créé par `create_user` des tests : #{new_user.id.inspect}"

  # Mettre en courant lorsqu'on en a fait explicitement la
  # demande ou lorsqu'un programme UN AN UN SCRIPT doit être
  # instancié pour l'auteur.
  User.current= new_user if mettre_courant

  return new_user
end

def make_user_subscriber_for new_user, programme_1a1s = false
  now = Time.now.to_i
end

# Détruit des users dans la table offline, sans toucher aux 10
# premiers
#
def remove_users upto = :all
  raise 'On ne doit plus détruire les users de cette façon.'
  drequest = {
    where: "id > 3",
    colonnes: []
  }
  case upto
  when Integer then drequest.merge!(limit: upto)
  when :all
    # Rien à faire
  end

  ids = User.table.select(drequest).collect{|h| h[:id]}

  # On les détruit dans la table
  User.table.delete(drequest)

  # On les détruit dans la table des paiements
  User.table_paiements.delete(drequest)

end
