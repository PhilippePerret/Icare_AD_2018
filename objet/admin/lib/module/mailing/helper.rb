# encoding: UTF-8
class Admin
class Mailing
class << self

  # Le contenu de la page, quand un mail est défini
  attr_writer :content


  # Sous-titre en fonction de l'étape de conception du mailing-list
  # On peut être à la composition du message, à sa validation ou à
  # son envoi.
  def sous_titre
    case param(:operation)
    when NilClass           then 'Composition du message'
    when 'prepare_mailing'  then 'Validation du mailing'
    when 'mailing_send'     then 'Envoi du message'
    else "Opération indéfinie : #{param :operation}"
    end
  end

  def content
    if param(:operation).nil?
      ''
    else
      (@content||'[PROBLÈME EN ÉTABLISSANT LE CONTENU]') + page.html_separator(80)
    end +
    # On met toujours le formulaire en bas
    mailing_form
  end

  # Retourne le fieldset des options pour le choix
  # des destinataires
  #
  def fieldset_cb_destinataires
    c = Admin::Mailing::KEYS_DESTINATAIRES.collect do |key, dkey|
      idname = "cb_dest_#{key}"
      dkey[:hname].in_checkbox(name: idname, id: idname, checked: dkey[:checked], class: 'cb_inline')
    end.join('').in_div(class: 'small')
  end


  # Retourne le fieldset des options de traitement
  #
  def fieldset_cb_options
    c = Admin::Mailing::OPTIONS.collect do |key, dkey|
      idname = "cb_option_#{key}"
      dkey[:hname].in_checkbox(name: idname, id: idname, checked: dkey[:value], class: 'cb_inline')
    end.join('').in_div(class: 'small')
  end


  # Liste des variables template
  #
  def div_variables_template
    Admin::Mailing.variables_template.collect do |key, dkey|
      kstr = "%{#{key}}".ljust(20)
      "#{kstr} #{dkey[:description]}\n"
    end.join('').in_pre(id: 'variables_templates', style: 'font-size:12pt;')
  end

end #/<< self
end #/Mailing
end #/Admin
