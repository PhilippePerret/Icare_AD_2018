# encoding: UTF-8
class Admin
class Taches
class << self

  # Retourne le formulaire pour créer une nouvelle tâche, caché, avec un
  # lien pour l'afficher et créer la nouvelle tâche.
  def formulaire_new_tache
    site.require 'form_tools'
    form.prefix = 'tache'
    f = (
      'create_tache'.in_hidden(name:'op') +
      form.field_text('Tâche', 'tache') +
      form.field_text('Échéance', 'echeance', nil, {class: 'medium', text_after: 'JJ/MM/AAAA ou +/-nombre jours'}) +
      form.submit_button('Créer').in_span(class: 'small')
    ).in_form(action:'admin/taches', id: 'form_new_tache').in_fieldset
    # Le formulaire doit être caché au départ, sauf s'il y a une
    # erreur
    displayed = @error_when_create ? 'block' : 'none'
    'Nouvelle tâche'.in_a(onclick: "$('div#div_form_new_tache').toggle()").in_div(class:'small right') +
    f.in_div(id: 'div_form_new_tache', display: @error_when_create != nil)
  end

end #<< self
end #/Taches
end #/Admin
