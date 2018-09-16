# encoding: UTF-8
class User
class << self

  # RETURN Une liste à fournir à as_select, contenant en premier
  # élément l'ID de l'user et en deuxième son pseudo.
  #
  # +options+ peut définir :
  #   :actif
  #   :inactif
  #   :en_attente
  #   :en_pause
  #   :detruit
  #
  def values_select options = nil
    options ||= Hash.new

    drequest = {
      order:    'LOWER(pseudo) ASC',
      colonnes: [:pseudo]
    }

    # Clause where
    whereclause = Array.new
    options[:en_attente]&& whereclause << 'SUBSTRING(options,17,1) = "1"'
    options[:actif]     && whereclause << 'SUBSTRING(options,17,1) = "2"'
    options[:en_pause]  && whereclause << 'SUBSTRING(options,17,1) = "3"'
    options[:inactif]   && whereclause << 'SUBSTRING(options,17,1) = "4"'
    if options[:detruit]
      whereclause << 'SUBSTRING(options,4,1) = "1"'
    else
      whereclause << 'SUBSTRING(options,4,1) != "1"'
    end
    # Ajout de la requête :where (toujours)
    drequest.merge!(where: whereclause.join(' AND '))

    template_pseudo = user.admin? ? "%{pseudo} (#%{id})" : "%{pseudo}"

    # Faire la liste et la retourner
    dbtable_users.select(drequest).collect do |huser|
      [huser[:id], (template_pseudo % {pseudo: huser[:pseudo].capitalize, id: huser[:id]})]
    end
  end

end #/<< self
end #/User
