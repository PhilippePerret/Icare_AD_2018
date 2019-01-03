# encoding: UTF-8
=begin

  Opérations sur les icariens ou un icarien en particulier
  --------------------------------------------------------

  MESSAGES DE SUIVI
  -----------------

  Utiliser la variable @suivi (Array) pour mettre des messages de
  résultat/suivi qui apparaitront au-dessus du formulaire d'opération à
  la fin de l'opération.

=end
raise_unless_admin

OFFLINE || page.add_javascript(PATH_MODULE_JS_SNIPPETS)

class Admin
class Users

  DATA_OPERATIONS = {
    ''                => {hname: 'Choisir l’opération…', short_value: nil, long_value: nil},
    'add_actualite'   => {hname: 'Ajouter actualité', long_value: "Message d'actualité à attribuer à l'icarien sélectionné. Le message sera évalué, donc on peut utiliser des `\#{icarien.pseudo}` à l'intérieur (code ruby évalué comme dans un String normal)."},
    'free_days'       => {hname: 'Jours gratuits', short_value: "Nombre de jours gratuits", long_value: "Raison éventuelle du don de jours gratuits (format ERB)."},
    'travail_propre'  => {hname: 'Travail propre', short_value: nil, long_value: "Description du travail propre (format ERB).<br>Laisser vide et cliquez sur “Exécuter” pour charger le travail qui peut déjà exister."},
    'inject_document' => {hname: 'Document envoyé par mail', medium_value: 'Nom du fichier'},
    'etape_change'    => {hname: 'Changement d’étape', short_value: 'Numéro de l’étape', long_value: nil},
    'code_sur_table'  => {hname: 'Exécution code sur données', short_value: nil, medium_value: nil, long_value: "Code à exécuter <strong>sur chaque icarien de la table</strong>, sur la table #{ONLINE ? 'ONLINE' : 'OFFLINE'} puis vous êtes #{ONLINE ? 'ONLINE' : 'OFFLINE'}.<br><br><code>dbtable_users.select.each do |huser|<br>&nbsp;&nbsp;uid = huser[:id]<br>&nbsp;&nbsp;u = User.new(uid)</code>"},
    'pause_module'    => {hname: 'Mise en pause du module d’apprentissage',short_value: "X pour ne pas envoyer l'email"},
    'restart_module'  => {hname: 'Reprise du module d’apprentissage après pause'},
    'arret_module'    => {hname: 'Arrêt d’un module d’apprentissage', long_value: 'Si un texte (en HTML) est écrit ci-dessous, il sera considéré comme le supplément d’un mail à envoyer à l’icarien du module l’informant de l’arrêt/la fin de son module. Dans le cas contraire, le module sera simplement arrêté.'},
    'change_module'   => {hname: 'Changement de module', short_value: 'ID du nouveau module absolu d’apprentissage (on peut le trouver avec l’outils Bureau > Édition des étapes, c’est le nombre entre parenthèses après le nom du module)', medium_value: 'Numéro de la nouvelle étape dans le nouveau module (on peut l’obtenir avec l’outil Burea > Édition des étapes)'},
    'temoignage'      => {hname: 'Nouveau témoignage', short_value: 'ID du témoignage si c’est une modification', medium_value: nil, long_value: "Code HTML du témoignage à ajouter"},
    'titre_projet'    => {hname: 'Définir le titre du projet', short_value: 'ID du IcModule si ça n’est pas le courant', medium_value: 'Titre du projet (ou rien pour le supprimer)'},
    'destroy_user'    => {hname: 'Destruction totale d’un icarien', short_value: 'ID de l’icarien si non choisi dans menu', medium_value: nil, long_value: nil}
  }
class << self

  def resultat
    if @suivi.nil?
      ''
    else
      (
        "=== SUIVI ET RESULTAT DE L’OPÉRATION ===\n\n" +
        @suivi.join("\n")
      ).in_pre(class: 'pre-wrap')
    end
  end

  def param_opuser
    @param_opuser ||= param(:opuser) || Hash.new
  end

  # ---------------------------------------------------------------------
  #   DATA DE L'OPÉRATION
  # ---------------------------------------------------------------------
  # Les deux valeurs : soit la courte, soit la longue
  def short_value
    @short_value ||= param_opuser[:short_value].nil_if_empty
  end
  def medium_value
    @medium_value ||= param_opuser[:medium_value].nil_if_empty
  end
  def long_value
    @long_value ||= param_opuser[:long_value].nil_if_empty
  end
  # :all, :actif, ou :inactif, :en_pause, :en_attente, :detruit
  def type_icarien
    @type_icarien ||= (param_opuser[:type_icarien]||'all').to_sym
  end
  # Icarien visé par l'opération
  def icarien ; @icarien ||= User.new(user_id) end
  def user_id ; param_opuser[:user_id].to_i end
  alias :icarien_id :user_id

  # ---------------------------------------------------------------------

  # Un menu pour choisir un user
  def menu
    User.values_select(type_icarien => true).in_my_select(id: 'opuser_user_id', name: 'opuser[user_id]', selected: param_opuser[:user_id])
  end
  def menu_type_icarien
    [
      ['all',         'Tous'],
      ['actif',       'actifs'],
      ['inactif',     'Inactifs'],
      ['en_pause',    'En pause'],
      ['en_atttente', 'En attente'],
      ['detruit',     'Détruits']
    ].in_my_select(name:'opuser[type_icarien]', id: 'opuser_type_icarien', onchange: "$.proxy(Dashboard,'onchoose_type_icarien')()", selected: type_icarien.to_s)
  end

  # Retourne le menu des opérations possibles
  def menu_operations
    Admin::Users::DATA_OPERATIONS
    .collect{|ope_id, hope| [ ope_id, hope[:hname] ]}
    .in_my_select(
      id: 'opuser_ope', name: 'opuser[ope]',
      onchange: "$.proxy(Dashboard,'on_choose_operation')()",
      selected: param_opuser[:ope],
      size: 'long'
      )
  end

  def execute_operation
    ope = param_opuser[:ope].nil_if_empty
    ope || return
    @suivi = Array.new
    Admin.require_module 'operations_user'
    (folder_operation + "#{ope}.rb").require
    method = "exec_#{ope}".to_sym
    if self.respond_to?(method)
      self.send(method)
    else
      add_error 'La méthode %s est inconnue…' % ope
    end
  end

  def folder_operation
    @folder_operation ||= site.folder_objet + 'admin/lib/module/operations_user'
  end

  def add_error err
    @suivi << '<span style="color:red">%s</span>' % err
  end

end #/<< self
end #/Users
end #/Admin

Admin::Users.execute_operation
