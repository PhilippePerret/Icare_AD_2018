# encoding: UTF-8
=begin

  Méthodes d'helper lorsque l'on arrive sur la page de paiement, pour
  initier le paiement et présenter le formulaire.

=end
class IcPaiement

  # Retourne le Code HTML du formulaire de paiement
  def formulaire_de_paiement
    "Objet : paiement du module “#{abs_module.name}” (#{abs_module.tarif} €)".in_p(class: 'bold') +
    (
      'Que vous ayez ou non un compte, vous pouvez effectuer votre paiement de façon tout à fait sécurisée avec Paypal.'.in_p(class: 'tiny') +
      'Procéder au paiement'.in_p                 +
      '_express-checkout'.in_hidden(name: 'cmd')  +
      token.in_hidden(name: 'token')              +
      'commit'.in_hidden(name: 'useraction')      +
      objet.in_hidden(name: 'description')        +
      '<img src="view/img/logo/paypal.png" />'
    ).in_form(id: 'form_paiement', class: 'cadre', action: self.class.url_paypal, onclick: 'this.submit()').
      in_div(class: 'center')
  end

  # Retourne le Code HTML de la page en cas d'erreur
  def page_when_erreur(e)
    "Une erreur est malheureusement survenue : #{e.message}…".in_p(class: 'warning')
  end

end #/IcPaiement
