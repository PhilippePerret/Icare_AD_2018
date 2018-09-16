# encoding: UTF-8
app.benchmark('-> user processus : valider_inscription')

def refus; @refus ||= param(:refus) end
def refus_texte; @refus_texte ||= refus[:motif].nil_if_empty end
def format_erb?; @is_format_erb ||= refus[:format] == 'on' end

def abs_module_id; @abs_module_id ||= param(:module_choisi).nil_if_empty.to_i_inn end

# Méthode pour le mail user_mail_refus
def motif_refus_candidature
  if format_erb?
    ERB.new(refus_texte).result(self.bind)
  else
    refus_texte.strip.split("\n").join("<br />").in_p(style:'color:red')
  end
end

# Instance AbsModule du module absolu choisi, pour information pour le mail
def absmodule
  @absmodule ||= begin
    site.require_objet 'abs_module'
    AbsModule.new(abs_module_id)
  end
end

is_refus = (refus_texte != nil)
is_refus  && abs_module_id  && raise('Choix ambigu : un texte de refus et un module choisi…')
!is_refus && !abs_module_id && raise('Choix ambigu : il faut choisir le module à attribuer ou écrire le motif de refus !')

if is_refus

  # REFUS DE L'INSCRIPTION
  # ----------------------
  @user_mail = folder + 'user_mail_refus.erb'
  # Il faut envoyer le mail à l'user avant de le détruire, sinon c'est
  # à l'administrateur que le mail est envoyé.
  send_mail_watcher_to_user
  # Et il faut indiquer ensuite de ne pas envoyer le mail
  no_mail_user
  # On procède à la destruction de l'user
  dbtable_users.delete(owner.id)
  flash "Inscription détruite."

else

  # VALIDATION DE L'INSCRIPTION
  # ---------------------------
  # On crée le module d'apprentissage (instance IcModule)
  site.require_objet 'ic_module'
  IcModule.require_module 'create'
  icmodule = IcModule.create_for(owner, abs_module_id)

  # On ajoute une actualité pour annoncer la nouvelle validation
  # de candidature.
  site.require_objet 'actualite'
  SiteHtml::Actualite.create(user_id: owner.id, message: "<strong>#{owner.pseudo}</strong> est reçu#{owner.f_e} à l'atelier.")

  # On marque que l'user est reçu
  owner.set(options: owner.options.set_bit(16,4)) #inactif

  # On détruit le fichier statistiques
  Atelier.remove_statistiques_file

  # Message final de confirmation
  flash "Inscription de #{owner.pseudo} (##{owner.id}) confirmée et module “#{absmodule.name}” (##{absmodule.id}) attribué."
end

app.benchmark('<- user processus :valider_inscription')
