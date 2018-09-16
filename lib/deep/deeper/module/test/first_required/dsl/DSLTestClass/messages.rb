# encoding: UTF-8
=begin

  Module gérant les messages (succès et failure) ainsi que
  tous les messages d'erreur et les notifications.

=end
class DSLTestMethod

  def non_fatal
    @is_not_fatal = true
  end
  alias :not_fatal :non_fatal

  def all_messages
    @all_messages ||= []
  end

  # Méthode-case qu'on peut utiliser pour enregistrer n'importe
  # quel message à écrire au fil du test
  #
  # Le nil en second élément signifie que ça n'est ni un succès
  # ni une failure
  def show mess
    all_messages << [mess, nil]
  end

  # ---------------------------------------------------------------------
  #   Helper methods
  #   --------------
  #   Cf. le fichier helper.rb
  # ---------------------------------------------------------------------


  def messages_count
    # @messages_count ||= success_messages.count + failure_messages.count
    @messages_count ||= all_messages.count
  end

  # ---------------------------------------------------------------------
  #   Message de programme (erreurs et notices)
  # ---------------------------------------------------------------------

  def error_no_test_route method
    @template_html ||= begin
      raise "Impossible d'utiliser la méthode `%{method}` avec une test-méthode qui n'est pas de type route. Pour que la test-méthode puisse utiliser ce test-case, ajouter `include ModuleRouteMethods` à son code."
    end
    @template_html % {method: method}
  end

end
