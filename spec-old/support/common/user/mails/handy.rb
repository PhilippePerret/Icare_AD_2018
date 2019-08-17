# encoding: UTF-8

# Vide le dossier des mails envoyés en local
def reset_mails
  MailMatcher.folder_mails_temp.remove if MailMatcher.folder_mails_temp.exist?
end
alias :remove_mails :reset_mails

# Retourne un {Array} de tous les mails envoyés en local
def get_mails
  MailMatcher.all_mails
end
