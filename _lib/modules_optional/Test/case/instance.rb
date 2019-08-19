# encoding: UTF-8

class TestUnsuccessfull < StandardError; end

class SiteHtml
class TestSuite
class Case

  # Instance de la test-method qui invoque ce
  # cas. C'est cette test-méthod qui va recevoir les messages
  attr_reader :tmethod

  # Arguments envoyés
  # Ces arguments définissent tout ce qu'il faut savoir, le résultat
  # "droit", l'inversion demandée (if any) et tous les messages en
  # fonction des cas.
  attr_reader :args

  # {True|False} Résultat de l'estimation
  attr_reader :result


  def initialize tmethod, args
    @tmethod  = tmethod || SiteHtml::TestSuite::TestFile.current_test_method
    @args     = args
  end

  # = main =
  #
  # Évaluation du cas, dispatche le message là où il
  # doit aller. Un succès enregistre le message dans l'instance
  # ATest courante, une failure fait sortir (raise) du test
  # courant.
  def evaluate
    unless tmethod.nil? # les tests
      tmethod.all_messages << [ message_final, !!successfull? ]
    end
    unless successfull?
      tmethod.is_not_a_success unless tmethod.nil? # tests de base
      raise TestUnsuccessfull if fatal?
    end
  end

  def fatal?
    @is_fatal ||= begin
      if tmethod.nil?
        true
      else
        tmethod.fatal?
      end
    end
  end

  def message_final
    @message_final ||= formate_message( uniq_message || (successfull? ? bon_message_success : bon_message_failure) )
  end

  # Le vrai résultat, en fonction du fait que le test est
  # inversé ou non ?
  def successfull?
    @is_successfull ||= (positif == args[:result])
  end

  def sujet_valeur ; @sujet_valeur ||= args[:sujet_valeur]||args[:valeur_sujet] end
  def objet_valeur ; @objet_valeur ||= args[:objet_valeur]||args[:valeur_objet] end
  def sujet_name   ; @sujet_name   ||= args[:sujet]||args[:sujet_name]  end
  def objet_name   ; @objet_name   ||= args[:objet]||args[:objet_name]  end

  def bon_message_success
    @bon_message ||= uniq_message || (positif ? message_success : message_success_not)
  end
  def bon_message_failure
    @bon_message_failure ||= uniq_message || (positif ? message_failure : message_failure_not)
  end

  def uniq_message        ; @message              ||= args[:message]        end
  def message_success     ; @message_success      ||= args[:on_success]     end
  def message_success_not ; @message_success_not  ||= args[:on_success_not] end
  def message_failure     ; @message_failure      ||= args[:on_failure]     end
  def message_failure_not ; @message_failure_not  ||= args[:on_failure_not] end
  # Test droit ou inverse ?
  # Note : :positif peut ne pas avoir été transmis, dans le cas où
  # la valeur de succès est déjà évaluée et qu'il y a un seul message
  # transmis, le message à afficher. Dans ces cas-là, il faut mettre
  # positif à true.
  def positif
    if @positif === nil
      @positif = args.key?(:positif) ? !!args[:positif] : true
    end
    @positif
  end

end #/Case
end #/TestSuite
end #/SiteHtml
