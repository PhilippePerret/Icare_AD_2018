# encoding: UTF-8
=begin
  Méthodes de simulation pour les icmodules de l'user
=end
class Simulate

  include RSpec::Matchers

  # Méthode qui simule l'inscription jusqu'au moment où l'administrateur
  # valide l'inscription et donne un module (args[:module]) à l'user
  #
  # La méthode :
  #   - met en new_user_id  l'id du user créé
  #   - met en premier watcher le watcher de l'attribution de module
  #   - met en second watcher le watcher de démarrage ('start') de module
  #
  # +args+
  #   :test       Si true, on teste que tout soit OK
  #               Par défaut : false
  #   :module     {Fixnum} L'ID du module d'apprentissage attribué
  #               Par défaut : 1
  #   :password   {String} Le mot de passe du nouveau user
  #   ... et toutes les propriétés possibles de l'user, :sexe, :naissance, etc.
  #
  def pre_start_module args
    # Simulation de l'inscription
    test_procedure = args[:test] || args.delete(:test_only_first)

    self.inscription args
    hw_attribut = watchers.first

    if test_procedure
      expect(self.user).not_to eq nil
      expect(self.user).not_to be_recu
      expect(self.user).to be_alessai
      success 'L’user est non reçu et à l’essai.'
      dreq = {where: {user_id: user_id, objet: 'user', processus: 'valider_inscription'}}
      expect(dbtable_watchers.count(dreq)).to eq 1
      'L’user a un watcher pour valider son inscription et attribuer un module.'
    end

    if test_procedure
      drequest = {where: {user_id: user_id}}
      nombre_modules_user_init = dbtable_icmodules.count(drequest)
      nombre_modules_user_init == 0 || dbtable_icmodules.delete(drequest)
      puts "#{self.user.pseudo} ne possède aucun ic-module."
    end

    # Pour procéder à l'acceptation de la candidature, on doit
    # mettre l'administrateur en user courant. On le simule grâce au fonctionnement
    # des routes par CURL avec _adm
    abs_module_id = args.delete(:module) || 1
    params  = {user_id: phil.id, module_choisi: abs_module_id, refus:{motif: ''}, redirect: 'bureau/home'}
    self.route "watcher/#{hw_attribut[:id]}/run", args.merge(test: test_procedure), params

    if test_procedure
      @user = User.new(user_id)
      expect(self.user).to be_recu
      expect(self.user).to be_alessai
      success 'L’user est maintenant reçu mais toujours à l’essai.'
      # Le watcher de paiement doit avoir été supprimé
      expect(dbtable_watchers.get(hw_attribut[:id])).to be nil
      success 'Le watcher de validation de l’inscription (`valider_inscription`) a été supprimé.'
      expect(dbtable_watchers.count(where:{user_id: user_id, objet: 'ic_module', processus: 'start'})).to be 1
      success 'Un watcher pour le démarrage du module a été créé.'
      drequest = {where: {user_id: user_id, abs_module_id: abs_module_id}}
      expect(dbtable_icmodules.count(drequest)).to eq 1
      success "L’ic-module a été instancié pour #{self.user.pseudo}."
    end

    # On récupère le watcher de start
    @watchers << dbtable_watchers.get(where: {user_id: user_id, processus: 'start'})

  end

  # Pour se placer au moment où l'icarien/ne vient de démarrer
  # son module d'apprentissage.
  def after_start_module args = nil
    test_procedure = args[:test] || args.delete(:test_only_first)
    pre_start_module args
    hwatcher_start  = watchers.last
    # puts "hwatcher_start : #{hwatcher_start.inspect}"
    wid_start       = hwatcher_start[:id]
    @user_id        = hwatcher_start[:user_id]
    @user           = User.new(@user_id)

    # Test préliminaire
    if test_procedure
      puts "ID du watcher de démarrage : #{wid_start}"
      puts "User id : #{@user_id}"
      nb = dbtable_watchers.count(where: {user_id: user_id, objet: 'ic_etape', processus: 'send_work'})
      expect(nb).to eq 0
      success 'Aucun watcher pour un rendu de travail n’existe pour le moment.'
    end

    # User.current = @user
    params = {redirect: 'bureau/home', user_id: @user.id}
    if test_procedure
      puts "Route jouée : `watcher/#{wid_start}/run` avec les paramètres : #{params.inspect}"
    end
    self.route "watcher/#{wid_start}/run", args.merge(test: test_procedure), params

    if test_procedure
      nb = dbtable_watchers.count(where: {user_id: user_id, processus: 'start'})
      expect(nb).to eq 0; success 'Le watcher de démarrage a été supprimé'
      nb = dbtable_watchers.count(where: {user_id: user_id, objet: 'ic_etape', processus: 'send_work'})
      expect(nb).to eq 1; success 'Un watcher d’envoi du travail (send_work) a été créé'
    end

    @watchers << dbtable_watchers.get(where:{user_id: @user_id, processus: 'send_work'})
  end

end #/Simulate
