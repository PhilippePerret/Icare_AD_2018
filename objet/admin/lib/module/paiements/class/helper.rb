# encoding: UTF-8
class Admin
class Paiements
class << self

  # Retourne le code HTML du formulaire pour choisir
  # une date de départ et une date de fin pour obtenir
  # les paiements
  def form_from_to
    site.require 'form_tools'
    form.prefix = 'fromto'
    'Paiements…'.in_a(href:'#', onclick:"$('form#paiements_form').toggle();return false").in_div    +
    (
      hidden_fields                   +
      field_from_date                 +
      field_to_date                   +
      form.submit_button('Calculer')
    ).in_form(id: 'paiements_form',action: "admin/paiements", method: 'POST', class: 'dim3070 small cadre', style: "margin:0;width:70%;display:#{options[:hide_form] ? 'none' : 'block'}")
  end

  def hidden_fields
    'afficher'.in_hidden(id: 'operation', name: 'operation') +
    # Pour pouvoir mettre automatiquement la dernière année
    (Time.now.year).in_hidden(id: 'current_year')
  end
  def field_from_date
    form.field_text('depuis le', 'from_date', nil, {class: 'medium', placeholder:'JJ/MM/AAAA', text_after: "Année #{bouton_last_year} #{bouton_next_year}"})
  end
  def bouton_last_year
    'précédente'.in_a(href: '#', onclick:'SetDatesPreviousYear();return false', class: 'tiny btn')
  end
  def bouton_next_year
    'suivante'.in_a(href:'#', onclick:'SetDatesNextYear();return false', class: 'tiny btn')
  end
  def field_to_date
    form.field_text('jusqu’au', 'to_date', nil, {class: 'medium', placeholder:'JJ/MM/AAAA', text_after: '(non compris)'})
  end
end #/Self
end #/Paiements
end #/Admin
