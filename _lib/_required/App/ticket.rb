# encoding: UTF-8
=begin
Extention de la class App pour la gestion des tickets
Ce sont les méthodes minimales qui sont toujours chargées.
Par exemple, la méthode `check_ticket` est toujours appelée
au chargement.
=end

class App

  # Méthode appelée par le préambule (./_lib/preambule.rb) pour
  # traiter l'éventuel ticket.
  def check_ticket
    # Pour éviter les redoublements de traitement au cours d'un même
    # chargement de page.
    return if param(:tckid).nil? || @ticket_already_checked
    site.require_module('Ticket')
    @ticket_already_checked = true
    execute_ticket(param(:tckid))
  end

  # Crée un ticket à partir des données +tid+ et +tcode+
  # +tid+ {String|NIL} ID à donner au ticket, en général un 32 bits
  #       La méthode en calcule un unique si NIL
  # +tcode+ {String} Le code ruby qui devra être exécuté à l'appel
  # du ticket.
  # Retourne le ticket créé, mais ne sert que pour les tests
  # +options+ Permet de passer des données qui ne pourront pas être
  # prises autrement, par exemple l'user_id lorsque c'est une création
  # d'user et qu'il n'y a donc pas de user courant.
  def create_ticket tid, tcode, options = nil
    site.require_module('Ticket')
    tid ||= begin
      require 'securerandom'
      SecureRandom.hex
    end
    @ticket = Ticket::new(tid, tcode, options)
    @ticket.create
    @ticket
  end

end
