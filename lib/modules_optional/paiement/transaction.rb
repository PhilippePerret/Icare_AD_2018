# encoding: UTF-8
class SiteHtml
class Paiement

  # = main =
  #
  # C'est la méthode principale qui doit être appelée
  # par la vue qui contient le traitement du paiement.
  # Pour l'utiliser, il suffit de mettre dans la vue :
  #   site.require_module('Paiement')
  #   site.paiement.make_transaction
  #
  def make_transaction data_transaction

    # # Pour voir les données envoyées
    # # ------------------------------
    # debug "-> SiteHtml::Paiement#make_transaction(data_transaction :"
    # debug data_transaction.pretty_inspect
    # debug ")"

    # Dispatch des données envoyées
    # [:context, :objet, :objet_id, :montant, :description]
    data_transaction.each{ |k, v| instance_variable_set("@#{k}", v) }

    # Par défaut, le context(e) est 'user'
    @context ||= 'user'

    case param(:pres)
    when '1'
      # On passe par ici lorsque le paiement a été effectué avec succès
      # par l'utilisateur. On peut enregistrer le paiement et informer
      # l'user de ce qu'il peut faire maintenant.
      # S'il venait de s'inscrire, on supprime sa variable session
      # 'for_paiement' qui le laissait provisoirement tranquille à propos
      # de la validation de son mail.
      res = on_ok
      app.session['for_paiement'] = nil
      # Je ne sais pas si cette méthode a besoin du résultat, mais je le
      # retourne quand même (en prévision des modifications futures).
      res
    when '0'
      # On passe par ici lorsque le paiement a été annulé par
      # l'user ou par PayPal lui-même
      on_cancel
    else
      # Première arrivée dans la section de paiement, on va
      # instancier la procédure de paiement.
      # La méthode `init` ci-dessous va envoyer la première requête
      # à Paypal, avec le description du paiement, pour obtenir un
      # ticket (token) que le site placera dans le formulaire de
      # paiement.
      # Ensuite, la page affichera le formulaire avec le logo PayPal
      # pour pouvoir payer (note : ce formulaire est défini dans la
      # page paiement.erb mais c'est une méthode d'helper qui fournit
      # le code du formulaire : site.paiement.form).
      init
      # Noter que le formulaire est par défaut le formulaire du
      # dossier `user'. Mais si le context possède un dossier
      # `paiement' avec un fichier `form', c'est ce formulaire
      # qui sera utilisé.
      # Il faut définir précisément les
      # propriétés :objet et :description transmises à la méthode
      # make_transaction pour modifier l'affichage.
      # Le context doit aussi pouvoir répondre à :montant pour fixer
      # le montant attendu.
      # Si vraiment une application doit utiliser des formulaires
      # différents en fonction du context, il faut modifier.
      self.output = Vue.new(form_affixe_path, nil, self).output
    end
  end

  # Path du formulaire
  # Soit le formulaire par défaut (./objet/user/paiement/form.erb) soit
  # le formulaire du contexte.
  def form_affixe_path
    @form_path ||= begin
      fp = site.folder_objet + File.join(context, 'paiement', 'form.erb')
      arr_dossiers = [ (fp.exist? ? context : 'user'),'paiement','form' ]
      File.join(*arr_dossiers)
    end
  end

  # = Main =
  #
  # Méthode appelée quand on arrive sur la page. Elle commence par appeler
  # SetExpressCheckout pour définir le paiement, afin de définir l'action
  # du formulaire du bouton PayPal. Note : L'icarien n'est pas encore sur la
  # page de paiement, elle lui sera affichée à la fin de ce processus.
  def init

    raise "Il faut fournir le montant du paiement (:montant)" if montant.nil?

    command = Command::new(self, "Initialisation du paiement")
    # On ajoute les "données clés" que sont la devise, les
    # URL OK et Cancel etc.
    command << data_key

    debug "url_retour_ok : #{url_retour_ok.inspect}"
    debug "url_retour_cancel : #{url_retour_cancel.inspect}"

    command << {
      method:                 "SetExpressCheckout",
      localecode:             "FR",
      cartbordercolor:        "008080",
      paymentrequest_0_amt:   montant_paypal,
      paymentrequest_0_qty:   "1"
      # # Détails
      # l_paymentrequest_0_name0:    "Module d'apprentissage #{current_user.current_module.name}",
      # l_paymentrequest_0_number0:  "#{current_user.current_module.id[3..-1]}"
    }

    # Exécution de la requête Paypal, sur le site PayPal
    command.exec

    # En cas de failure, on affiche le message d'erreur
    raise command.error if command.failure?

    # On définit le numéro du ticket, par commodité en propriété
    # du paiement, en l'empruntant à la commande.
    @token = command.token

  rescue Exception => e
    debug e
    error "Un problème est malheureusement survenue au cours de l'instanciation du paiement (#init) : #{e.message}"
  end

  # Méthode appelée suite au paiement réussi par l'user
  # Noter qu'il faut encore valider le paiement auprès de
  # Paypal et l'enregistrer sur le site
  def on_ok
    @token    = param(:token)
    @payer_id = param(:PayerID)
    if valider_paiement
      self.output = Vue.new("#{context}/paiement/on_ok", nil, self).output
    else
      self.output = Vue.new("#{context}/paiement/on_error", nil, self).output
    end
  end

  # Méthode appelée suite à l'annulation ou l'impossibilité
  # d'exécuter le paiement.
  def on_cancel
    self.output = Vue.new("#{context}/paiement/on_cancel", nil, self).output
  end

  # Enregistrer le paiement
  #
  # On enregistre le paiement dans la table des paiements et
  # on appelle ensuite la méthode `on_paiement` qui va permettre
  # notamment de créer l'enregistrement dans la table des
  # autorisations en fonction du paiement.
  def save_paiement
    User.table_paiements.insert(data_paiement)
    User.new(data_paiement[:user_id]).on_paiement(data_paiement)
  end

  # Envoyer un mail de confirmation à l'user
  def send_mail_to_user
    # debug "-> send_mail_to_user"
    site.send_mail(
      from:     site.mail,
      to:       user.mail,
      subject:  'Confirmation de votre paiement',
      message:  facture,
      formated: true
    )
  end

  # Envoyer le mail à l'administration pour informer du
  # paiement
  def mail_administration_annonce_paiement
    # return # pour faire échouer les tests
    mess = <<-TXT
<p>Phil,</p>
<p>Je te fais part d'un nouvel abonnement, celui de :</p>
<pre>PSEUDO : #{user.pseudo} IDENTIFIANT : ##{user.id}</pre>
<p>Facture envoyée à #{user.pseudo} :</p>
#{table_facture}
    TXT

    site.send_mail_to_admin(
      subject:  'Nouvel abonnement au site',
      message:  mess,
      formated: true
    )
  end

  # {StringHTML} Retourne le code pour la facture
  def facture
    @facture ||= begin
      <<-HTML
<p>Bonjour #{user.pseudo},</p>
<p>Veuillez trouver ci-dessous votre facture pour votre dernier paiement.</p>
<p>Bien à vous et au plaisir ! :-)</p>
#{table_facture}
<p>#{site.name}</p>
      HTML
    end
  end

  def table_facture
    @table_facture ||= begin
      <<-HTML
<style type="text/css">
table#facture{border:2px solid}
table#facture tr{border: 1px solid}
table#facture td{padding: 1px}
</style>
<table id="facture">
  <colsgroup>
    <col width="150" />
    <col width="450" />
  </colsgroup>
  <tr>
    <td>Facture ID</td>
    <td>#{token}</td>
  </tr>
  <tr>
    <td>Émise par</td>
    <td>#{site.official_designation}</td>
  </tr>
  <tr>
    <td>Pour</td>
    <td>#{user.patronyme || user.pseudo} (##{user.id})<br />#{user.mail}</td>
  </tr>
  <tr>
    <td>Objet</td>
    <td>#{objet}</td>
  </tr>
  <tr>
    <td>Date</td>
    <td>#{Time.now.to_i.to_i.as_human_date}</td>
  </tr>
  <tr>
    <td>Montant</td>
    <td>#{montant_humain}</td>
  </tr>
</table>
      HTML
    end
  end

end # /Paiement
end # /SiteHtml
