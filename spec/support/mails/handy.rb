# encoding: UTF-8

def mail_should_have_been_sent(hdata)
  expect(hdata).to have_been_sent
  # On retourne le dernier mail trouvé
  TMailMatchers::Matchers::HasBeenSent.last_mail_found
end

# Vide le dossier des mails envoyés en local
def reset_mails
  TMail.folder_mails.remove if TMail.folder_mails.exist?
end
alias :remove_mails :reset_mails

# Retourne un {Array} de tous les mails envoyés en local
def get_all_mails
  TMail.all_mails
end
