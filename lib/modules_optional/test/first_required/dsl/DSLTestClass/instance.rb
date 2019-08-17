# encoding: UTF-8
=begin

Ouvrir le fichier Test/Implémentation/DSLTestMethod.md pour obtenir
tous les détails

=end
class DSLTestMethod

  # {SiteHtml::TestSuite::TestFile} Instance du fichier
  # possédant la méthode de test.
  attr_reader :__tfile

  # {Fixnum} Indice de la test-méthode courante dans le
  # fichier.
  attr_reader :indice_test_method

  # {String} Ligne depuis laquelle a été appelée la
  # méthode de test. Elle est tirée de caller.
  attr_accessor :line

  # Instanciation commune à toutes les méthode de test
  def initialize __tfile, &block
    @__tfile = __tfile
    @indice_test_method = __tfile.itest_method += 1

    # On la met en méthode courante de la class de fichier
    # de test
    SiteHtml::TestSuite::TestFile.current_test_method = self

    init

    begin
      # C'est ici qu'on évalue tout le contenu du bloc de test
      instance_eval(&block) if block_given?
    rescue TestUnsuccessfull
      # On passe par ici lorsqu'un test-case échoue
      # Il n'y a rien de particulier à faire puisque TestCase a
      # géré l'enregistrement du message d'erreur (on aurait pu
      # l'envoyer ici, mais la méthode `evaluate` de TestCase est
      # plus facile à lire comme ça)
      #
      # On ajoute cet échec au fichier
      __tfile.failure_tests << self
    rescue Exception => e
      # On passe ici si c'est une erreur systémique
      debug e
      self.all_messages << [ "ERREUR SYSTÉMIQUE : #{e.message}", false ]
      __tfile.failure_tests << self
    else
      # On peut ajouter ce succès au fichier
      __tfile.success_tests << self
    end
  end

  # Initialisation de la méthode de test
  def init
    # Les données du test, qui serviront notamment pour
    # l'affichage.
    @tdata = {
      test_file:            @__tfile, # instance TestFile du fichier
      start_time:           Time.now,
      end_time:             nil,
      description:          "",
      description_defaut:   nil
    }
    if self.respond_to?(:description_defaut)
      @tdata.merge!(description_defaut: description_defaut)
    end
  end

  # Pour indiquer qu'il y a eu des erreurs
  def is_not_a_success
    @is_not_a_success = true
  end


  # Pour ré-initialiser la session
  #
  # Noter que cela consiste simplement à détruire le
  # fichier qui conserve l'HEADER de la page pour CURL
  def reset_session
    SiteHtml::TestSuite::Request::CURL::reset_session
  end

  # Pour mettre le mode en verbose (même si le fichier ou les tests
  # généraux ont leur options différentes)
  def verbose value = true  ; @verbose = value end
  # Pour mettre quiet à true ou false
  def quiet value = true; @quiet = value end

end
