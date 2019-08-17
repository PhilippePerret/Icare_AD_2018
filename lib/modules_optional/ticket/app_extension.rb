# encoding: UTF-8
class App

  # Exécute le ticket
  # -----------------
  # Cette méthode est appelée par le site, au chargement de la
  # page, si une variable tckid est définie.
  # La méthode vérifie que le ticket existe bien, en revanche il
  # ne vérifie pas que c'est bien le possesseur du ticket qui
  # l'exécute.
  def execute_ticket tid
    get_ticket(tid)
    if false == @ticket.exist?
      error.add "Impossible d'exécuter ce ticket. Il n'existe pas ou plus."
    # elsif (user.id != ticket.user_id) && false == user.admin?
    #   error.add "Vous n'êtes en aucun cas le possesseur de ce ticket, impossible de l'exécuter pour vous."
    else
      @ticket.exec
    end
  end

  def save_ticket
    ticket.save
  end

  def get_ticket tid
    @ticket = Ticket::new(tid)
    return nil unless @ticket.exist?
    @ticket
  end

  # Détruit le ticket si l'exécution s'est bien déroulée
  def delete_ticket
    ticket.delete
  end

  def ticket(tid = nil) ; @ticket ||= get_ticket(tid) end

  # La table contentant les tickets
  # On peut l'obtenir par `app.table_tickets` mais il faut :
  # site.require_module 'ticket'
  def table_tickets
    @table_tickets ||= site.dbm_table(:hot, 'tickets')
  end

end #/App
