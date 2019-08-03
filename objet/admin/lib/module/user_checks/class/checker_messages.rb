=begin
  Méthodes pour les messages
=end
class Admin
class Checker
class << self
  #
  # def add_raw str, data = nil
  #   @msg << str.in_div(data)
  # end
  # def add label, str, data = nil
  #   label = label.ljust(20)
  #   @msg << "#{label} : #{str}".in_div(data)
  # end
  # def add_title str
  #   @msg << str.in_div(class: 'title')
  # end
  # def add_check label, str, resultat
  #   add label, str, {class: resultat ? 'green' : 'red'}
  # end
  # def add_error str
  #   @msg << str.in_div(class: 'data-error')
  # end
  # def add_fatal_error str
  #   @msg << "[ERREUR FATALE] #{str}".in_div(class:'data-error')
  #   @msg << "                Je ne pourrai pas corriger cette erreur.".in_div(class:'data-error')
  # end
  # def add_action str
  #   @msg << str.in_div(class: 'action')
  # end
  # def add_solution sol_id, str
  #   # Si cet identifiant existe déjà, il faut générer une erreur système
  #   if @solution_keys.key?(sol_id)
  #     raise "La clé-solution '#{sol_id}' existe déjà. Il faut changer son nom."
  #   else
  #     @solution_keys.merge!(sol_id => true)
  #   end
  #   @msg << "#{str}".in_checkbox({name:sol_id, checked:true}).in_div(class:'solution')
  # end

end #/<< self
end #/Checker
end #/Admin
