# encoding: UTF-8
=begin

  Module requis pour le paiement du module.
  -----------------------------------------
  Ce module sert principalement à définir les dépassements de paiement,
  et compagnie.

=end

# ---------------------------------------------------------------------
#   Méthodes d'helper
# ---------------------------------------------------------------------

# Returne "N jours" en mettant ou non un "s"
#
# Noter que "N" est toujours positif.
def nb_jours_h
  @nb_jours_h ||= begin
    nb_jours = diff_jours >= 0 ? diff_jours : -diff_jours
    s = nb_jours > 1 ? 's' : ''
    "#{nb_jours} jour#{s}"
  end
end

# Retourne un texte comme "votre module “Analyse de films”"
def votre_module_name
  @le_module ||= "votre module “#{icmodule.abs_module.name}”"
end

# ---------------------------------------------------------------------
#   Méthodes fonctionnelles
# ---------------------------------------------------------------------

# L'IcModule visé par ce paiement
def icmodule            ; @icmodule           ||= self.instance_objet     end
def time_next_paiement  ; @time_next_paiement ||= icmodule.next_paiement  end

# Instance IcPaiement pour le paiement du module
#
def icpaiement
  @icpaiement ||= begin
    site.require_objet 'ic_paiement'
    param(:paie_id) != nil || raise('paie_id ne devrait pas être nil…')
    pment = IcPaiement.new(param(:paie_id).to_i)
    if pment.montant.to_s == ''
      debug "Le montant est nil ici je le fixe de force"
      pment.instance_variable_set("@montant", icmodule.abs_module.tarif)
      debug "pment.montant mis à : #{pment.montant.inspect}"
    end
    pment
  end
end

# La différence en jours entre le jour courant et le paiement.
# Si cette différence est POSITIVE, on est AVANT le paiement
# Si cette différence est NÉGATIVE, on est APRÈS le paiement
# Si cette différence est ZÉRO, c'est le jour du paiment.
def diff_jours
  @diff_jours ||= begin
    if time_next_paiement.nil?
      # Un problème se pose ici : le watcher de paiement ne fait
      # référence à aucun paiement.
      # Pour le mmoment, en attendant de voir où se pose le problème,
      # je renvoie une valeur absurde pour traiter derrière.
      # On avertit l'administration
      begin
        mail_message = <<-HTML
<p>Phil, il semble y avoir un problème de watcher de paiement non supprimé :</p>
<pre>
  Icarien    : #{owner.pseudo} (##{owner.id})
  Icmodule   : ##{icmodule.id}
  Icpaiement : ##{icpaiement.id} (#{icpaiement.montant.inspect} €)
</pre>
        HTML
        send_mail_to_admin(
          subject:  'Problème de watcher de paiement',
          message:  mail_message,
          formated: true
          )
      rescue Exception => e
      end
      10000
    else
      (time_next_paiement - Time.now.to_i) / 1.day
    end
  end
end


# État du paiement en fonction du nombre de jours
# Si le positif, l'état est   :proche
# Si zéro, l'état est         :today
# Si négatif < -4             :requis
# Si négatif < -14            :urgent
# Si négatif < -31            :redhib
def paiement_state
  @paiement_state ||= begin
    case true
    when diff_jours > 9999  then :lointain
    when diff_jours > 0     then :proche
    when diff_jours == 0    then :justnow
    when diff_jours > -5    then :requis
    when diff_jours > -14   then :urgent
    when diff_jours > -31   then :grave
    when diff_jours < -30   then :redhib
    end
  end
end

# Le message du paiement en fonction de l'état, à mettre dans le
# formulaire de paiement.
def message_by_state
  @message_by_state ||= begin
    case paiement_state
    when :lointain
      "#{owner.pseudo}, vous n’avez aucun paiement en cours."
    when :proche
      "#{owner.pseudo}, le paiement de “#{votre_module_name}” doit être effectué dans #{nb_jours_h}."
    when :justnow
      "#{owner.pseudo}, vous pouvez procéder aujourd'hui au paiement de #{votre_module_name}."
    when :requis
      "Merci de bien vouloir procéder au paiement de #{votre_module_name} afin de pouvoir le poursuivre."
    when :urgent
      "#{votre_module_name.capitalize} doit être payé depuis #{nb_jours_h}."
    when :grave
      "Vous auriez dû payer pour #{votre_module_name} depuis #{nb_jours_h}. Merci de procéder rapidement à cette opération. Dans le cas contraire, vous mettriez en péril votre participation à l'atelier Icare."
    when :redhib
      "Vous n'avez pas payé #{votre_module_name} après #{nb_jours_h}. Nous sommes malheureusement contraints de procéder à la destruction sans appel de votre inscription à l'atelier Icare."
    end
  end
end
