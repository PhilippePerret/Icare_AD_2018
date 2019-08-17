# encoding: UTF-8
class App
class Ticket

  include MethodesMySQL

  attr_reader :id

  def initialize tid, tcode = nil, options = nil
    @id   = tid
    @code = tcode
    options.each { |k, v| instance_variable_set("@#{k}", v) } unless options.nil?
  end

  # Retourne le lien pour activer le ticket (à copier
  # dans le mail)
  # @usage : Utiliser la méthode app.ticket.link après avoir
  # utilisé app.create_ticket(id,code)
  def link titre = nil
    titre ||= href
    titre.in_a(href:href)
  end

  # Exécution du ticket (exécute le code enregistré dans la
  # base de données)
  def exec
    eval(code)
  rescue Exception => e
    raise e
  else
    delete
    return true
  end

  def href
    "#{site.distant_url}?tckid=#{id}"
  end

  def save
    if exist?
      table.update({where: "id LIKE '#{id}'"}, data2save)
    else
      create
    end
  end

  # Retourne true si le ticket existe. Noter la tournure LIKE au
  # lieu du test simple d'égalité. Cela tient simplement au fait
  # que si l'identifiant se termine par "8" la valeur est trans-
  # formée, sans doute en octal. En revanche, LIKE transforme
  # forcément le test en string
  def exist?
    table.count(where: "id LIKE '#{id}'") > 0
  end

  def create
    table.insert(data4create)
  end

  def data4create
    @data4create ||= {
      id:         id,
      code:       code,
      user_id:    @user_id || user.id,
      created_at: Time.now.to_i,
      updated_at: Time.now.to_i
    }
  end

  def data2save
    @data2save ||= {
      code:         code,
      user_id:      user_id,
      updated_at:   Time.now.to_i
    }
  end

  def user_id   ; @user_id  ||= get(:user_id) end
  def code      ; @code     ||= get(:code)    end

  def table
    @table ||= app.table_tickets
  end

end #/Ticket
end #/App
