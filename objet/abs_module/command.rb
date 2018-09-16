# encoding: UTF-8
=begin
  Module permettant :
    - de m'informer de la commande du module
    - d'enregistrer le choix de l'icarien (un watcher)
=end
raise_unless_identified

def absmodule
  @absmodule ||= AbsModule.new(param(:mid).to_i)
end

debug "user pour le watcher de command.rb : #{user.pseudo} (##{user.id})"
user.add_watcher(
  objet:      'abs_module', objet_id: absmodule.id,
  processus:  'command'
)
site.send_mail_to_admin(
  subject:        'Commande d’un module d’apprentissage',
  formated:       true,
  # force_offline:  true,
  message: <<-TXT
  <p>Phil, je t'informe de la commande d'un nouveau module :</p>
  <pre>
  Icarien : #{user.pseudo} (##{user.id})
  Module  : #{absmodule.name} (##{absmodule.id})
  Date    : #{NOW.as_human_date(true, true, ' ', 'à')}
  </pre>
  <p>Tu peux rejoindre #{lien.bureau('ton bureau', online: true)} pour l’attribuer.</p>
  TXT
)
