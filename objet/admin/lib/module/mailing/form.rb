# encoding: UTF-8
=begin
  Formulaire pour définir le mail à transmettre, les
  destinataires et les options.
=end
class Admin
class Mailing
class << self

  # = main =
  #
  # Formulaire de définition du mailing
  #
  def mailing_form
    site.require 'form_tools'
    form.prefix = 'mail'

    f = 'prepare_mailing'.in_hidden(name: 'operation')
    f += form.field_text('Sujet', 'subject')
    f += form.field_raw('Message', '', nil, {field: '<hr><div>Bonjour &lt;pseudo&gt;,</div>'})
    f += form.field_textarea('', 'message')
    f += form.field_raw('', '', nil, {field: '<div>&lt;signature&gt; (cf. ci-dessous)</div><hr>'})
    f += form.field_raw('Destinataires', '', nil, {field: Admin::Mailing.fieldset_cb_destinataires})
    f += form.field_raw('Options', '', nil, {field: Admin::Mailing.fieldset_cb_options})
    f += form.submit_button('Préparer l’envoi')
    f.in_form(id: 'form_mailing', class: 'dim2080', action: 'admin/mailing')
  end
  
end #/<< self
end #/ Mailing
end #/ Admin
