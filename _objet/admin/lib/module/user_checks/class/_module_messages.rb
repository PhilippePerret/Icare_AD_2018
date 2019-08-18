=begin
  Méthodes pour les messages
=end
module MessagesMethods

  def msg
    @msg ||= Admin::Checker.msg
  end
  def solution_keys
    @solution_keys ||= Admin::Checker.solution_keys
  end
  def now
    Admin::Checker.now
  end

  def add_raw str, data = nil
    msg << str.in_div(data)
  end
  def add label, str, data = nil
    data ||= {}
    data.merge!(class:'res')
    label = "#{label} ".ljust(40,'.')
    msg << (label.in_span(class:'label') + "#{str}".in_div(class:'texte')).in_div(data)
  end
  def add_title str
    msg << str.in_div(class: 'title')
  end
  def add_info label, str
    add label, str, {class: 'blue'}
  end
  def add_check label, str, resultat
    add label, str, {class: resultat ? 'green' : 'red'}
  end
  def add_error str
    msg << str.in_div(class: 'data-error')
  end
  def add_fatal_error str
    msg << "[ERREUR FATALE] #{str}".in_div(class:'data-error')
    msg << "                Je ne pourrai pas corriger cette erreur.".in_div(class:'data-error')
  end
  def add_action str
    msg << str.in_div(class: 'action')
  end
  def add_solution sol_id, str
    # Si cet identifiant existe déjà, il faut générer une erreur système
    if solution_keys.key?(sol_id)
      raise "La clé-solution '#{sol_id}' existe déjà. Il faut changer son nom."
    else
      solution_keys.merge!(sol_id => true)
    end
    msg << "#{str}".in_checkbox({name:sol_id, checked:true}).in_div(class:'solution')
  end

  def correct sol_id, sol_msg, db_suffix, tbl_name, id, column, value = nil
    Admin::Checker.correct(sol_id, sol_msg, db_suffix, tbl_name, id, column, value)
  end

end #/Module
