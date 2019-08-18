# encoding: UTF-8
=begin

  Processus de démarrage d'un module d'apprentissage

  Doit être fourni en paramètre :

    :module_id      Identifiant du module

  Déclenché par un watcher de données :
    objet:      'ic_module'
    objet_id:   ID de l'ic-module dans la base
    user_id:    ID de l'user qui doit démarrer le module

=end
app.benchmark('-> processus `start` de `ic_module`')

# RETURN la date du prochain paiement, en fonction du fait que
# c'est un premier module ou non
def time_next_paiement
  if dbtable_paiements.count(where: {user_id: owner.id}) > 0
    # Si l'user a déjà des modules
    Time.now.to_i
  else
    # Si c'est le premier module de l'user
    Time.now.to_i + 10.days
  end
end

# Vérification que c'est bien le propriétaire du module
# qui vient le démarrer.
icmodule.user_id == owner.id || raise('L’utilisateur n’est pas le bon pour l’ic-module donné.')
icmodule.user_id == user.id  || raise('Désolé, mais vous n’êtes pas en mesure de démarrer ce module d’apprentissage. Il ne vous appartient pas.')

# ---------------------------------------------------------------------
#   DÉBUT DES OPÉRATIONS DE DÉMARRAGE
#
#   L'opération doit :
#
#     POUR L'IC-MODULE
#     ----------------
#     - indiquer que l'ic-module (créé lors de la validation de
#       l'inscription ou de l'attribution d'un nouveau module) a été
#       mis en route. Son premier bit d'options est mis à 1
#     - indiquer l'ic-étape dans la donnée du module
#     - définition de la date de prochain paiement.
#     - création du watcher de paiement
#
#     POUR L'IC-ÉTAPE
#     ---------------
#     - créer une ic-étape pour le module, la première
#     - créer un watcher pour remettre les documents de cette étape
#
#     POUR L'USER
#     -----------
#     - indiquer qu'il est actif (bit 16)
#     - on l'associe à son module dans ses données (icmodule_id)
#
#     AUTRES
#     ------
#     - annonce de l'actualité, démarrage d'un nouveau module
#
# ---------------------------------------------------------------------


# {Hash} pour mettre les nouvelles données de l'user
new_data_user     = Hash.new
# {Hash} Pour mettre les nouvelles données de l'icmodule
new_data_icmodule = Hash.new


# Créer une première ic-étape
# ---------------------------
site.require_objet 'ic_etape'
icetape = IcModule::IcEtape.create_for(icmodule, 1)

# Identifiant de l'étape dans les données du module
new_data_icmodule.merge!(icetape_id: icetape.id)

# Passer le premier bit des options du module à 1
new_data_icmodule.merge!(options: icmodule.options.set_bit(0, 1))

# On associe l'user à son icmodule
new_data_user.merge!(icmodule_id: icmodule.id)

# On marque que l'user est actif
new_data_user.merge!(options: owner.options.set_bit(16,2)) #actif

# Définir la date de prochain paiement et la date de démarrage
new_data_icmodule.merge!(
  next_paiement:  time_next_paiement,
  started_at:     Time.now.to_i
  )

# Watcher de prochain paiement
# === Watcher paiement ===
owner.add_watcher(
  objet:      'ic_module',
  objet_id:   icmodule.id,
  processus:  'paiement',
  triggered:  time_next_paiement - 3.days
)

# Watcher pour remettre les documents de l'étape
owner.add_watcher(
  objet:      'ic_etape',
  objet_id:   icetape.id,
  processus:  'send_work'
)

# Actualité
# ---------
site.require_objet 'actualite'
SiteHtml::Actualite.create(
  user_id: owner.id,
  message: "<strong>#{owner.pseudo}</strong> démarre son module d’apprentissage “#{abs_module.name}”. Bon courage à #{owner.femme? ? 'elle' : 'lui'} !",
)

# On détruit le fichier statistiques
Atelier.remove_statistiques_file

# On enregistre toutes les nouvelles données
icmodule.set(new_data_icmodule)
owner   .set(new_data_user)


flash "Bravo #{owner.pseudo}, votre module d’apprentissage est démarré !"

app.benchmark('<- processus `start` de `ic_module`')

User.current= User.new(owner.id)
redirect_to 'bureau/home'
