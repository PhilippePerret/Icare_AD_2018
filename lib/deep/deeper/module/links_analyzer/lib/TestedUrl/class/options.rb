# encoding: UTF-8
=begin

  Module de gestion des options du programme.

  Ce module a été initié pour traiter les options qui seraient
  passés par la ligne de commande.

=end
class TestedPage

  OPTIONS_DIM = {
    'd' => 'depth',
    'D' => 'dumped-data',
    'f' => 'report-format',
    'h' => 'help',
    'i' => 'infos',
    'm' => 'max-routes',
    'o' => 'online',
    'r' => 'from-route',
    'v' => 'verbose',
    'x' => 'code-html'
  }
  DATA_OPTIONS = {
    'code-html'     => {hname: 'Affichage du code HTML de la page', report: 'Code HTML de la page'},
    'depth'         => {hname: 'Profondeur des fouilles', report: "Profondeur de la recherche"},
    'dumped-data'   => {hname: 'Reprise des données enregistrées', report: 'Reprise des données enregistrées'},
    'from-route'    => {hname: 'La route initiale', report: 'Route initiale'},
    'help'          => {hname: 'Aide'},
    'infos'         => {hname: 'Informations sur les liens relevés'},
    'max-routes'    => {hname: 'Nombre maximum de routes testées', report: 'Nombre maximum de routes'},
    'online'        => {hname: 'Test en ONLINE', report: 'Recherche ONLINE'},
    'fail-fast'     => {hname: 'Interruption à la première erreur'},
    'report-format' => {hname: 'Format du rapport de sortie'},
    'verbose'       => {hname: 'verbosité'}
  }
  class << self

    attr_reader :options

    def analyze_options

      ARGV.each do |arg|
        offset_egal = arg.index('=')
        k, v =
          if offset_egal.nil?
            [arg, nil]
          else
            [arg[0..offset_egal-1], arg[offset_egal+1..-1]]
          end
        opt =
          if k.start_with?('--')
            k[2..-1]
          elsif k.start_with?('-')
            OPTIONS_DIM[ k[1..2] ]
          end

        val  = (v == nil || v == '') ? true : v

        @options.merge!(opt => val )
      end

      # On met les options par défaut pour toutes celles qui
      # ne sont pas définies
      options_par_default

    end

    # Après avoir récupéré les options, on peut mettre les
    # valeur par défaut
    def options_par_default

      # Route initiale
      @options['from-route'] ||= begin
        if defined?(FROM_ROUTE) && FROM_ROUTE != nil
          FROM_ROUTE
        else
          'site/home' # la route par défaut
        end
      end

      # Verbosité du programme
      # => verbose?
      options.key?('verbose') || @options['verbose'] = VERBOSE
      # Interruption de l'analyse dès la première erreur
      # => fail_fast?
      options.key?('fail-fast') || @options['fail-fast'] = FAIL_FAST
      # Nombre maximum de routes testées
      options.key?('max-routes') || @options['max-routes'] = NOMBRE_MAX_ROUTES_TESTED
      unless @options['max-routes'].nil?
        @options['max-routes'] = @options['max-routes'].to_i
      end

      # Format de rapport de sortie
      options.key?('report-format') || @options['report-format'] = REPORT_FORMAT || :html
      @options['report-format'] = options['report-format'].to_sym
      # Test en online ?
      # => online?
      options.key?('online') || @options['online'] = !!TEST_ONLINE
      # Profondeur maximum
      options.key?('depth') || @options['depth'] = DEPTH_MAX
      unless @options['depth'].nil?
        @options['depth'] = @options['depth'].to_i
      end
      # Informations en suivant l'analyse
      # => info?
      options.key?('infos') || @options['infos'] = !!SHOW_ROUTES_ON_TESTING
      # Reprise des données dans le fichier marshal pour ne pas
      # recommencer l'analyse
      # => dumped_data?
      options.key?('dumped-data') || @options['dumped-data'] = !!USE_DUMPED_DATA
      # Faut-il afficher le code HTML de la page dans le rapport ? (false
      # par défaut)
      options.key?('code-html') || @options['code-html'] = false

    end


    def verbose?
      options['verbose'] # -v
    end
    def aide?
      options['help'] # -h
    end
    alias :help? :aide?
    # Retourne TRUE si le test doit se faire online
    def online?
      options['online'] # -o
    end
    def fail_fast?
      options['fail-fast']
    end
    def depth_max
      @depth_max ||= options['depth']
    end
    def infos?
      options['infos']
    end
    def dumped_data?
      options['dumped-data']
    end
    def show_code_html?
      options['code-html']
    end


  end #/ << self TestedPage
end #/TestedPage
