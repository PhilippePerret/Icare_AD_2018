# encoding: UTF-8
=begin

  Méthodes
  --------

    User#a_recu_un_mail <data_mail>
    User#napas_recu_un_mail <data mail>
    User#napas_recu_de_mail

=end
class User

  # C'est la méthode utilisée pour les chaines-méthodes
  #
  # Note : il faut absolument l'utiliser avec les méthodes de chaine pour
  # obtenir un message de retour.
  # @usage:     Untel recoit le mail <Hash data mail>
  #
  def recoit_le_mail dmail, options = nil
    options ||= Hash.new
    self.mail != nil || begin
      duser = dbtable_users.get(self.id)
      duser != nil || raise("IMPOSSIBLE D’OBTENIR L’USER ##{self.id} DANS LA TABLE users.users…")
      duser.each{|k,v|instance_variable_set("@#{k}",v)}
    end
    self.mail != nil || raise("AUCUN MAIL DÉFINI POUR LA RECHERCHE PAR MAIL ! IMPOSSIBLE DE TESTER LES MAILS.")
    mess_success = options.delete(:success) || "#{pseudo} a reçu le mail avec les paramètres #{dmail.inspect}"
    dmail.merge!(to: self.mail)
    MailMatcher.search_mails_with dmail
    nombre_mails = MailMatcher.mails_found.count
    if nombre_mails > 0
      success mess_success
      true
    else
      raise "#{pseudo} n'a reçu aucun mail correspondant aux paramètres demandés."
    end
  end
  alias :a_recu_le_mail :recoit_le_mail

  # Idem que précédente
  def ne_recoit_pas_le_mail dmail, options = nil
    options ||= Hash.new
    dmail.merge!(to: self.mail)
    MailMatcher.search_mails_with dmail
    nombre_mails = MailMatcher.mails_found.count
    if nombre_mails == 0
      true
    else
      raise "#{pseudo} a malheureusement reçu un mail correspondant aux paramètres demandés."
    end
  end
  alias :napas_recu_le_mail :ne_recoit_pas_le_mail



  def napas_recu_de_mail
    mails = MailMatcher.search_mails_with(to: self.mail)
    if mails.count == 0
      success "#{pseudo} n'a reçu aucun mail."
    else
      raise "#{pseudo} n'aurait dû recevoir aucun mail."
    end
  end
end
