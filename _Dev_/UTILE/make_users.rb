# encoding: UTF-8
=begin

  Fabrication des users de base

  Phil      1     Administrateur
  Benoit    2     Un icarien
  Marion    3     Une icarienne

  Pour les créer, il suffit de copier/coller par exemple dans le fichier
  site/home.rb le code :

    require './_Dev_/UTILE/make_users'


=end
require 'digest/md5'
require './data/secret/data_phil'
require './data/secret/data_benoit'
require './data/secret/data_marion'

site.dbm_table(:users, 'users').delete

[DATA_PHIL, DATA_BENOIT, DATA_MARION].each do |udata|

  now = Time.now.to_i

  # Noter que le salt n'est pas utilisé pour Icare
  pwd = udata.delete :password
  cpassword = Digest::MD5.hexdigest("#{pwd}#{udata[:mail]}")

  udata.merge!(
    patronyme: "#{udata[:sexe] == 'F' ? 'Madame' : 'Monsieur'} #{udata[:pseudo]}",
    salt: '', # parce que le sel n'est pas utilisé
    cpassword: cpassword,
    options: udata.delete(:default_options),
    created_at: now,
    updated_at: now
  )

  site.dbm_table(:users, 'users').insert(udata)

end
# /Fin de boucle sur chaque user pour le créer
