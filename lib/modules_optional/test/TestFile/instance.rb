# encoding: UTF-8
# ---------------------------------------------------------------------
#   Instance SiteHtml::TestSuite::File
#
#   Une instance d'un fichier de test
#
# ---------------------------------------------------------------------
class SiteHtml
class TestSuite
class TestFile

  # {SiteHtml::TestSuite} Instance de la suite de ce fichier
  attr_reader :test_suite

  # {String} Path du test
  attr_reader :path

  # {String} Nom du test
  # C'est le nom général, défini par exemple par `test_route`
  attr_reader :test_name

  # {Fixnum} Indice du fichier test courant dans la suite
  # complète des tests.
  attr_accessor :itest_file

  # {Array} Liste des messages de succès. En fait, c'est une
  # liste d'instances ATest
  # La seconde liste contient les messages d'échec
  attr_reader :success_tests
  attr_reader :failure_tests

  # {Fixnum} Indice de la test-méthode courant.
  attr_accessor :itest_method

  # +tsuite+  SiteHtml::TestSuite courante (possédant ce fichier)
  def initialize tsuite, path
    @test_suite = tsuite
    @path       = path
    @success_tests = Array::new
    @failure_tests = Array::new
    # Pour pouvoir numéroter les test-méthodes du fichier de
    # test.
    @itest_method  = 0
  end

  # = main =
  #
  # Méthode principale lançant l'exécution du code
  # de tout le fichier
  #
  # TODO Plus tard, il faudra jouer ça dans un thread
  # isolé.
  def execute
    self.class::class_eval do
      define_method(:run) do
        eval(File.open(path,'rb'){|f| f.read})
      end
    end
    run
  rescue NotRunOnline
    test_suite.files_out << [self.path, "seulement en offline"]
  rescue NotRunOffline
    test_suite.files_out << [self.path, "seulement en online"]
  rescue Exception => e
    debug e
    error e.message
  end

  # Affichage de la path dans un lien permettant d'ouvrir
  # le fichier dans l'éditeur de préférence
  def clickable_path
    @clickable_path ||= lien.edit_file(File.expand_path(path.to_s), titre: path.to_s, editor: :atom, class: 'inherit')
  end

  def log mess
    self.class::log mess
  end

  # Pour mettre en route le débug lorsque ces méthodes sont à la
  # "racine" du fichier (i.e. pas dans une test-méthode)
  def debug_start;  SiteHtml::TestSuite::debug_start  end
  def debug_stop;   SiteHtml::TestSuite::debug_stop   end

  # Pour mettre le mode en verbose (même si le fichier ou les tests
  # généraux ont leur options différentes)
  def verbose value = true  ; @verbose = value end
  # Pour mettre quiet à true ou false
  def quiet value = true; @quiet = value end

end #/TestFile
end #/TestSuite
end #/SiteHtml
