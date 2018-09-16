# encoding: UTF-8
=begin

  Instances MailMatcher
  ---------------------
  Gestion des mails pour les tests

=end
class MailMatcher

  attr_reader :data
  attr_reader :subject, :message, :created_at, :from, :to

  # Si true, on affiche les messages de suivi
  attr_accessor :verbose

  # Instancitation, avec les données qui sont relevées (démarshalisées)
  # dans le fichier enregistré
  def initialize data
    @data = data
    data.each{ |k,v| instance_variable_set("@#{k}", v)}
  end

  # Contenu du message, certainement contenu dans une balise
  # div#message_content si le message est au format HTML
  #
  # La méthode retourne le contenu de la première balise div
  # dans le div#message_content s'il la trouve et le message
  # complet dans le cas contraire.
  #
  def message_content
    if message.match(/id="message_content"/)
      dochtml = Nokogiri::HTML(message)
      # dochtml.css('div#message_content > div:first').inner_html
      inner = dochtml.css('div#message_content').inner_html
      # Et on supprime la signature et la suite si elles existent
      offset = inner.index('<span id="signature"')
      inner = inner[0..offset-1].strip if offset.to_i > 0
      inner
    else
      message
    end
  rescue Exception => e
    debug e.message
  end

end
