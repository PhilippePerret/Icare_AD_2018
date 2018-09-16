# encoding: UTF-8
=begin
  Ensemble de méthode pour "benchmarker" l'application.
  L'idée est d'enregistrer chaque fois le temps d'arriver dans les
  méthodes et d'enregistrer le compte rendu dans un fichier log

  Ce fichier log est remplacé à chaque chargement de page, ou peut être
  conservé si App::KEEP_BENCHMARK_LOG est à true

  @usage

    Note : les "<-", "->" etc. sont purement conventionnel, ils
    n'interviennent pas dans le programme.

    app.benchmark '-> ma méthode'  # entrée dans une méthode
    app.benchmark '<- sortie d'une méthode' # sortie d'une méthode
    app.benchmark '--> appel_methode' # appel d'une méthode
    app.benchmark '<-- appel_method'  # retour de la méthode

    DÉMARRAGE

      Il vaut mieux laisser le benchmark fonctionner de lui-même
      grâce à un fichier ./.start_time qui est enregistré au lancement
      de l'application.

      Mais on peut cependant utiliser :

        app.benchmark_start

      … si on ne veut que benchmarker un point précis du programme
      Tous les autres serton alors évités du rapport.

    FIN

      app.benchmark_fin

      La méthode écrit le rapport dans le fichier ./debug_benchmark.log
      si demandé.

    ÉCRITURE DU RAPPORT

      app.report

      La méthode est automatiquement appelée en fin de processus si
      App::BENCHMARK_ON n'est pas mis à false

=end
class App

  # Pour l'écriture du fichier, la largeur du texte pour écrire les
  # noms des méthodes ("-> ma méthode")
  LIBELLE_WITH_RETRAIT_SIZE = 54

  # Mettre à TRUE pour obtenir le rapport de benchmark, sinon à
  # false
  BENCHMARK_ON = true

  # Pour savoir s'il faut conserver où détruire le fichier log à
  # chaque chargement.
  KEEP_BENCHMARK_LOG = false

  # +time+ est précisé par exemple si on doit appeler la méthode
  # autre part qu'à l'endroit où on veut prendre le temps
  def benchmark method_name, time = nil
    @benchmark ||= Benchmark.new(self)
    @benchmark.add(method_name, time)
  end

  def benchmark_start
    @benchmark ||= Benchmark.new(self)
    @benchmark.set_start
  end
  def benchmark_fin
    BENCHMARK_ON || return
    @benchmark.report
  end

  class Benchmark

    RETRAIT_DEBUG = '      | '


    # {App} L'application
    attr_reader :app
    attr_reader :list

    def initialize app
      @app  = app
      @list = Array.new
      App::KEEP_BENCHMARK_LOG || remove_log_file
    end

    # Pour ne commencer le rapport de benchmark qu'à
    # partir de ce temps
    def set_start
      @from_time = Time.now.to_f
    end
    def from_time; @from_time || 0 end


    def add method_name, time = nil
      App::BENCHMARK_ON || return
      @list << [method_name, time || Time.now.to_f]
    end

    # Le temps de lancement du programme. À l'appel du fichier index,
    # un fichier ./.start_time est enregistré avant tout autre
    # processus pour écrire le temps.
    # Si ce fichier n'a pas pu être écrit, on prend le premier
    # temps enregistré
    def start_time
      @start_time ||= begin
        if File.exist?('./.start_time')
          File.open('./.start_time','wb'){|f| f.read}.to_f
        else
          list.first[1]
        end
      end
    end
    # Méthode qui affiche le rapport final dans un fichier
    def report
      code = ''
      App::KEEP_BENCHMARK_LOG && code += "\n\n"
      code +=  "=== BENCHMARK DU #{Time.now.to_i.as_human_date(true, true, ' ', 'à')} ===\n"
      code += "=== Index start : #{start_time} (#{Time.at(start_time)})\n\n"
      current_time = start_time
      current_retrait = 0
      code +=
        list.collect do |method_name, time|
          time > from_time || next
          t = time - start_time
          time_from_start = ("%.6f" % t).rjust(10)
          t = time - current_time
          elapsed_time    = ("%.6f" % t).rjust(10)
          current_time = time.to_f

          if method_name.start_with?('<- ')
            current_retrait -= 1
            current_retrait >= 0 || current_retrait = 0
          end

          libelle =
            if method_name.start_with?('DEBUG:')
              lines = method_name[6..-1].strip.split("\n")
              lastline = (RETRAIT_DEBUG + lines.pop.strip).ljust(LIBELLE_WITH_RETRAIT_SIZE)
              lines =
                if lines.count > 0
                  lines.collect do |line|
                    (RETRAIT_DEBUG + line.strip).ljust(LIBELLE_WITH_RETRAIT_SIZE) + ' - '.rjust(20)
                  end.join("\n")
                else '' end
              lines + "\n" + lastline
            else
              '  ' * current_retrait + method_name
            end

          # Construction de la ligne finale avec le bon retrait
          method_with_retrait = libelle.ljust(LIBELLE_WITH_RETRAIT_SIZE) + elapsed_time + time_from_start

          if method_name.start_with?('-> ')
            current_retrait += 1
          end

          method_with_retrait
        end.compact.join("\n")
      File.open(logfile, App::KEEP_BENCHMARK_LOG ? 'a' : 'wb'){|f| f.write code }
    rescue Exception => e
      code = e.message + e.backtrace.join("\n")
      File.open(logfile, App::KEEP_BENCHMARK_LOG ? 'a' : 'wb'){|f| f.write code }
    end

    # Destruction du fichier log
    # L'opération se fait à l'instanciation sauf s'il faut le
    # conserver
    def remove_log_file
      File.unlink(logfile) if File.exist?(logfile)
    end

    # Le fichier qui contiendra le benchmark. Il est détruit à
    # chaque chargement de page si App::KEEP_BENCHMARK_LOG est false
    def logfile
      @logfile ||= File.join('.','debug_benchmark.log')
    end

  end #/Benchmark
end #/App
