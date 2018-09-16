# encoding: UTF-8
class IcPaiement

  def page_on_confirmation_ok
    conf_mess = ''
    user.alessai? && conf_mess << "Vous êtes maintenant un#{owner.f_e} vrai#{owner.f_e} icarien#{owner.f_ne} !".in_p
    conf_mess << "Nous vous remercions de votre confiance et vous souhaitons bonne continuation au sein de l'atelier Icare !".in_p
    (
      'Votre paiement a été effectué avec succès.'.in_p +
      conf_mess
    ).in_div(class: 'air') +
    'Veuillez trouvez ci-dessous votre facture (qui vous est également transmise par mail)'.in_p(class: 'small') +
    facture_html
  end

  def page_on_confirmation_not_ok
    "Une erreur s'est produite : #{res_do[:l_shortmessage0]} / #{res_do[:l_longmessage0]}".in_p(class: 'air')
  end

  def page_on_error_operation(e)
    send_error_to_admin(exception: e, from: 'IcPaiement#page_on_error_operation')
    "Une erreur fonctionnelle s'est malheureusement produite : #{e.message}."
  end

end #/IcPaiement
