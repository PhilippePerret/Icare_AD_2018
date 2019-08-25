# encoding: UTF-8
class TMail
class << self

  attr_reader :mails

  # On charge tous les messages qui se trouvent dans le dossier des
  # messages envoyés en offline
  def load_all_mails
    @mails =
      Dir["#{folder_mails}/*.yaml"].collect do |fmail|
        TMail.new(YAML.load_file(fmail), File.basename(fmail))
      end
  end

  # Méthode qui recherche les messages pouvant correspondre à la table hdata
  # et les retourne
  def search hdata
    mails || load_all_mails
    founds = []
    mails.each do |mail|
      founds << mail if mail.matches?(hdata)
    end
    if VERBOSE && founds.count == 0
      # Si le mode verbose est activé et qu'on n'a trouvé aucun mail,
      # on passe en revue tous les mails pour indiquer pourquoi ils n'ont
      # pas été retenus
      puts "\n\n---# RECHERCHE DE MAIL INFRUCTUEUSE avec #{hdata.inspect}"
      mails.each do |mail|
        puts "--- ERREURS RENCONTRÉES PAR LE MAIL #{mail.fname} :"
        puts "\t- #{mail.errors.join("\t- ")}"
      end
    end
    return founds
  end

  def folder_mails
    @folder_mails ||= (site.folder_tmp+'mails')
  end
end #/<< self
end #/<< TMail
