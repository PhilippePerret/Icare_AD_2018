# encoding: UTF-8
=begin

  Module de création d'un nouveau IcModule d'apprentissage pour un user

  Noter que contrairement à l'ancien atelier, l'ic-module est créé ici
  dès l'attribution par l'administrateur.

=end
class IcModule
class << self

  # = main =
  #
  # Méthode principale pour initier un IcModule pour l'user. Elle est
  # appelée à la validation de la candidature, par l'administrateur
  # (processus ic_module/attribut_module)
  #
  # Note : contrairement à l'ancien formule, cette instance est créée
  # avant que le module ne soit démarré, pour simplifier la procédure
  # `start` enclenchée par l'user.
  #
  # +owner+         {User} Propriétaire du module d'apprentissage
  # +abs_module_id+ {Fixnum} IDentifiant du module d'apprentissage
  #
  # RETURN L'instance IcModule du module initié.
  #
  # Noter qu'il n'est pas encore mis dans les données de l'user, donc
  # que ça n'est pas encore son module courant.
  def create_for owner, abs_module_id
    icmodule = IcModule.create_icmodule_for(owner, abs_module_id)
    icmodule_id = icmodule.id
    # === Watcher de démarrage de module d'apprentissage ===
    owner.add_watcher(
      objet:      'ic_module',
      objet_id:   icmodule_id,
      processus:  'start'
    )
    # Vérification de la création du watcher
    drequest = {where: {user_id: owner.id, objet_id: icmodule_id, processus: 'start'}}
    dbtable_watchers.count(drequest) == 1 || raise('Le watcher de démarrage de module est introuvable.')
    # On retourne l'instance IcModule
    return new(icmodule_id)
  end


end #/<< self
end #/IcModule
