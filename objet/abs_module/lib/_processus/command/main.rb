# encoding: UTF-8
=begin
  Processus pour procéder à l'attribution d'un module à un icarien

=end
def param_command
  @param_command ||= param(:command)
end
def refus?
  @is_refus = param_command[:refus] == '1'
end
def no_mail_refus?
  @need_no_mail_refus ||= refus? && param_command[:no_mail] == 'on'
end
def motif_refus
  @motif_refus ||= param_command[:motif_refus]
end


def procedure_attribution_module

  # On crée le module d'apprentissage (instance IcModule)
  # C'est cette procédure qui créera un watcher pour le démarrage
  # du module.
  site.require_objet 'ic_module'
  IcModule.require_module 'create'
  icmodule = IcModule.create_for(owner, absmodule.id)

  flash "Module “#{absmodule.name}” attribué à #{owner.pseudo}."
end
def procedure_refus_module
  debug "param_command : #{param_command.inspect}"
  if no_mail_refus?
    # Quand il ne faut pas envoyer de mail
    debug "Pas de mail de refus"
    no_mail_user
  else
    # Il faut envoyer le mail de refus, auquel sera ajouté le
    # motif du refus.
    debug "Il faut un mail de refus"
    @user_mail = folder + 'user_mail_refus.erb'
  end
  flash "Module “#{absmodule.name}” REFUSÉ à #{owner.pseudo}."
end



if refus?
  procedure_refus_module
else
  procedure_attribution_module
end

# dont_remove_watcher # TODO SUPPRIMER QUAND TOUT SERA OK AVEC LES TESTS
