# encoding: UTF-8
=begin

  Handy helper méthodes
  Des méthodes pour simplifier l'écriture des codes

  Ce module est placé dans le dossier Page, mais il n'est
  pas vraiment lié à l'instance. Ces méthodes se trouve au
  top et peuvent s'employer sans instance.

=end

# +path+ depuis le dossier ./view/img
def image path, options = nil
  options ||= Hash.new
  path = (site.folder_images + path).to_s
  path.in_image(options)
end

# Pour afficher un gros message dans la page, comme par
# exemple un message de confirmation après l'envoi d'un
# mail.
# +messages+ Soit le message, soit la liste des messages, dont
#             chacun sera affiché l'un en dessous de l'autre.
# +options+   {Hash} des options. Si :ok est true, c'est un succès,
#             (défaut) si :ok est false, c'est une erreur.
#             Détermine la coche à employer
def big_message messages, options = nil
  messages.instance_of?(Array) || messages = [messages]
  options ||= {}
  options.key?(:ok) || options[:ok] = true
  coche = options[:ok] ? '√' : '🚫'
  (
    coche.in_div(style: 'font-size:38.7pt;color:#00dd00;font-family:Helvetica,Arial;') +
    messages.collect do |mess|
      mess.in_div
    end.join('')
  ).in_div(class: 'big center')
end

# Méthodes qui construisent notamment le titre du
# logo du site avec une première lettre qui se
# détache du reste (class span.first_letter_main_link)
# pour former le logo "BOA"
# On s'en sert aussi dans la marge gauche pour reprendre
# le visuel avec le mot "Outils"
def main_link( titre, uri = nil, options = nil )
  options ||= Hash.new
  options[:class] = options.key?(:class) ? [options[:class]] : Array.new
  options[:class] << ['mainlink']
  site.route?(uri) && options[:class] << 'current'
  options[:class] = options[:class].join(' ')
  options.merge!(href: uri)
  as_main_link(titre).in_a(options)
end
# +style+ On peut ajouter du contenu pour l'attribut style
def as_main_link titre, style = nil
  dtitre = titre.split('')
  first_letter = dtitre.shift
  other_letters = dtitre.join('')
  sty = style.nil? ? "" : " style=\"#{style}\""
  "<span class='first_letter_main_link'#{sty}>#{first_letter}</span>" +
  "<span class='other_letters_main_link'#{sty}>#{other_letters}</span>"
end
