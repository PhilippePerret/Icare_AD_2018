# encoding: UTF-8
=begin

  Matchers have_mail et have_mails

=end
class User

  include ::RSpec::Matchers

  def recoit_les_mails data_mails
    expect(self).to have_mails(data_mails)
  end

end

RSpec::Matchers.define :have_mails do |params|
  match do |qui|
    @qui      = qui
    @params   = params || Hash.new

    # # Pour voir les paramètres transmis
    # puts "@params : #{@params.inspect}"

    # Noter que ci-dessous on ne définit :to que s'il n'est pas défini
    # Cela est utile pour les procédures de destruction de l'user qui
    # empêcheraient de trouver qui.mail. Dans ces cas-là, il faut ajouter
    # la propriété `:to` aux paramètres en la renseignant avec la valeur
    # de mail qui aura été mise de côté avant.
    @params   = @params.merge(to: qui.mail) unless @params.key?(:to)
    @only_one = @params.delete(:only_one)
    # On cherche les mails
    MailMatcher.search_mails_with @params
    if @only_one
      MailMatcher::mails_found.count == 1
    else
      MailMatcher::mails_found.count > 0
    end
  end
  failure_message do |qui|
    "Aucun mail n'a été trouvé avec les paramètres fournis. #{MailMatcher::message_added}"
  end
  failure_message_when_negated do |qui|
    "Des mails (@mails_found.count) ont été trouvés avec les paramètres fournis…"
  end
  description do
    if @only_one
      "Le mail spécifié a été trouvé."
    else
      "Des mails ont été trouvés."
    end
  end
end

RSpec::Matchers.define :have_mail do |params|
  match do |owner|
    owner.instance_of?(User) || raise('Il faut fournir un User à la méthode de test `have_mail` !')
    expect(owner).to have_mails((params || {}).merge(:only_one => true))
  end
  failure_message do |owner|
    params ||= Hash.new
    params[:to] ||= owner.mail
    if MailMatcher::mails_found.count > 1
      "Plusieurs mails adressés à #{params[:to]} ont été trouvés, avec les paramètres transmis…"
    else
      # En cas d'erreur lorsqu'on cherche un mail
      "Aucun mail adressé à #{params[:to]} n'a été trouvé avec les paramètres #{params.inspect}.\n#{MailMatcher::message_added}"
    end
  end
  failure_message_when_negated do |owner|
    params ||= Hash.new
    params[:to] ||= owner.mail
    "Un mail a été adressé à #{params[:to]} avec les paramètres #{params.inspect}"
  end
  description do
    params ||= Hash.new
    params[:to] ||= owner.mail
    "Un mail a été adressé à #{params[:to]} avec les paramètres fournis."
  end
end
