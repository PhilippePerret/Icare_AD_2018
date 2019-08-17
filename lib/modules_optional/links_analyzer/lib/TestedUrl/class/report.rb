# encoding: UTF-8
=begin

=end
class TestedPage
  class << self

    # = main =
    #
    # Établissement du rapport d'analyse des liens
    #
    def report

      case options['report-format']
      when :html
        report_html
      else
        report_console
      end
      # / Fin du case format
    end

    # Retourne la durée de l'opération totale d'analyse, en
    # secondes, pour les infos générales
    #
    def duree_operation
      seconds = end_time.to_i - start_time.to_i
      minutes = seconds / 60
      seconds = seconds % 60
      s_mns = minutes > 1 ? 's' : ''
      s_scs = seconds > 1 ? 's' : ''
      hduree = "#{seconds} sec#{s_scs}"
      minutes == 0 || hduree = "#{minutes} mn#{s_mns} #{hduree}"
      return hduree
    end

    def pages_sorted_by_calls
      @pages_sorted_by_calls ||= begin
        instances.values.sort_by{ |v| v.call_count }
      end
    end

    def routes_les_plus_visitees nombre = 20
      nombre < pages_sorted_by_calls.count || nombre = (pages_sorted_by_calls.count - 1)
      pages_sorted_by_calls[-nombre..-1].reverse
    end
    def routes_les_moins_visitees nombre = 10
      pages_sorted_by_calls[0..nombre]
    end

    # Produit et ouvre le rapport HTML
    def report_html
      Report.html_version
    end

  end #/ << self TestedPage

  class Report
  class << self

    # Raccourci
    def options
      @options ||= TestedPage.options
    end

    # = main =
    # Construit la version HTML du rapport et l'ouvre
    #
    def html_version
      File.open(path,'wb'){|f| f.write code_html}
      `open -a '#{BROWSER_APP}' #{path}`
    end

    # Titre humain du rapport
    def titre
      "Links Analysis du #{Time.now.strftime('%d %m %Y à %H:%M')}"
    end

    # = main =
    #
    # Retourne le code pour les infos générales sur
    # l'analyse.
    def general_infos
      c = String.new


      # Nombre total de routes testées
      c << in_div(
        in_span(TestedPage.instances.count, class: 'fvalue') +
        in_span('Nombre de routes testées', class: 'libelle'),
        class: 'ligne_value'
      )

      # Nombre total de liens
      c << in_div(
        in_span(TestedPage.links_count, class: 'fvalue') +
        in_span('Nombre total de liens', class: 'libelle'),
        class: 'ligne_value'
      )

      # Nombre d'invalidités (rouge)
      css = ['fvalue']
      css << 'warning' if TestedPage.invalides.count > 0
      c << in_div(
        in_span(TestedPage.invalides.count, class: css.join(' ')) +
        in_span('Nombre de routes invalides', class: 'libelle'),
        class: 'ligne_value'
      )

      # Indication de la durée totale de l'opération
      c << in_div(
        in_span(TestedPage.duree_operation, class: 'fvalue') +
        in_span('Durée de l’opération', class: 'libelle'),
        class: 'ligne_value'
      )

      # Nombre de routes exclues
      c << in_div(
        in_span(TestedPage.routes_exclues_count, class: 'fvalue') +
        in_span("Nombre de routes exclues", class: 'libelle'),
        class: 'ligne_value'
      )

      # Options choisies
      # ----------------
      # On ne prend pas les options dont la valeur est false
      # ou nil
      options_choisies = options.collect do |k, v|
        # Si la propriété :report de l'option n'est pas définie,
        # c'est qu'il ne faut pas l'afficher dans le rapport. Et inversement,
        # toute propriété :report présente indique qu'on peut afficher l'option
        # dans le rapport (si elle est définie)
        DATA_OPTIONS[k].key?(:report) || (next nil)
        case v
        when FalseClass then next
        when NilClass
          case k
          when 'depth' then v = Float::INFINITY
          else next
          end
        end
        in_div(
          in_span("#{v}", class: 'fvalue') +
          in_span(DATA_OPTIONS[k][:report], class: 'libelle'),
          class: 'ligne_value'
        )
      end.compact.join('')
      c << options_choisies

      return c.force_encoding('utf-8')
    end

    # = main =
    #
    # Méthode principale retournant le code pour le fieldset des
    # fréquences, avec les routes les plus visitées, les moins visitées,
    # etc.
    def rapport_frequence
      c = String.new

      cmost =
        in_div('Routes les plus visitées', class: 'stitre') +
        TestedPage.routes_les_plus_visitees.collect do |tpage|
          in_div(
            in_span("#{tpage.call_count} fois", class: 'fright') +
            in_span("#{tpage.link_to}")
            )
        end.join('')

      cless = in_div('Routes les moins visitées', class: 'stitre') +
        TestedPage.routes_les_moins_visitees.collect do |tpage|
          in_div(
            in_span("#{tpage.call_count} fois", class: 'fright') +
            in_span("#{tpage.link_to}")
            )
        end.join('')

      in_tag('section', cless, class: 'colLow') +
      in_tag('section', cmost, class: 'colHigh')
    end


    # = main =
    #
    # Méthode principale renvoyant le code pour indiquer les
    # invalidités des pages.
    # Return '' si aucune route invalide n'a été trouvée.
    #
    def rapport_invalidites

      return '' if TestedPage.invalides.empty?
      # # Pour le test :
      # TestedPage.instance_variable_set('@invalides', TestedPage.instances.keys[0..4])

      in_tag('fieldset',
        in_tag('legend', "Routes/pages invalides (#{TestedPage.invalides.count})") +
        TestedPage.invalides.collect do |route|
        tpage = TestedPage[route]

        # Par erreur, il peut arriver que la page
        # n'existe pas. Peut-être lorsque le merge
        # s'est mal passé ou qu'on n'a pas pu trouvé la route dans les
        # invalides.
        tpage != nil || next

        # Identifiant du div qui contiendra la route invalide
        div_id = "div_route_#{route.gsub(/\//,'_')}".gsub(/[^a-zA-Z0-9_]/,'')

        lien_fermeture = "<a href=\"javascript:void(0)\" onclick=\"DOMRemove('#{div_id}','invalides')\">x</a>"
        bouton_fermeture = in_span(lien_fermeture, class: 'btn_close')

        # Pour indiquer la route et pouvoir l'atteindre
        main_line = in_div(
          in_span("<a href='#{tpage.url}' target='_blank'>#{tpage.url}</a>", class: 'link_url') +
          in_span(tpage.route, class: 'route'),
          class: 'main'
            )

        errors_list =
          tpage.errors.collect do |err|
            in_div(err, class: 'error')
          end.join('')
        div_errors_list = in_div(errors_list, class: 'errors_list')
        div_nombre_errors =
          in_div(
            in_span('Nombre d’erreurs', class: 'libelle') +
            in_span(tpage.errors.count, class: 'value')
          )
        # Un lien pour ouvrir un des referrer de la route, c'est-à-dire
        # une page qui l'ouvre.
        referrer = TestedPage[tpage.call_froms.last]
        link_to_referrer =
         case referrer
         when NilClass then '- aucun referrer trouvé -'
         else
           "<a href='#{referrer.url}' target='_blank'>#{referrer.url}</a>"
         end
        div_link_to_referrer =
          in_div(
            in_span('Appelée par exemple par…', class: 'libelle') +
            in_span(link_to_referrer, class: 'value')
          )

        # Le code HTML de la page, si demandé
        pre_raw_code =
          if TestedPage.show_code_html?
            in_div('Code brut de la page (ci-dessous, glisser la souris pour le faire apparaitre)') +
            in_tag('pre', tpage.raw_code_report, class: 'raw_code')
          else
            ''
          end

        codeline =
          bouton_fermeture      +
          main_line             +
          div_link_to_referrer  +
          div_nombre_errors     +
          div_errors_list       +
          pre_raw_code          +
          ''

        in_div(
          codeline,
          class: 'ligne_value bad_route',
          id: div_id
        )

      end.join("\n\n\n"),
      id: 'invalides'
      ) #/ in_tag('fieldset')

    end

    # = main =
    #
    # Code à déposer dans le fieldset des données de toutes les routes
    #
    # Ce code est mis dans un PRE (cf. gabarit.erb)
    def data_all_routes
      entete = in_div(''.ljust(8) + ''.ljust(60) + ''.ljust(6) + ''.ljust(6) + '    Depth'.ljust(14)) +
        in_div('-'*100) +
        in_div('Index'.ljust(8) + 'Route'.ljust(60) + 'Links'.ljust(6) + 'Calls'.ljust(6) + ' min  moy  max ' + 'Errs'.rjust(4)) +
        in_div('-'*100)


      {
        :route        => {titre: 'routes (alphabétique)', reverse: false},
        :call_count   => {titre: 'nombre d’appel depuis autres pages (calls)', reverse: true},
        :depth_max    => {titre: 'profondeurs (depth max)', reverse: false},
        :errors_count => {titre: 'nombre d’erreurs (errs)', reverse: true},
        :links_count  => {titre: 'nombre de liens sortants (links)', reverse: true}
      }.collect do |skey, dkey|

        # Classement suivant la clé
        sorted_data = TestedPage.instances.sort_by{|k, v| v.send(skey) }
        sorted_data = sorted_data.reverse if dkey[:reverse]

        div_id = "alldata_#{skey}"

        # Index de la route
        indexr = 0

        # Code HTML pour ce classement courant
        "<h3><a href=\"javascript:void(0)\" onclick=\"toggleElement('#{div_id}')\">Classement par #{dkey[:titre]}</a></h3>" +
        "<div id='#{div_id}' style='display:none'>" +
        entete +
        sorted_data.collect do |route, tpage|

          iroute    = (indexr += 1).to_s.rjust(7) + ' '
          froute    = tpage.route.ljust(60)
          nb_links  = tpage.links_count.to_s.ljust(6)
          nb_froms  = tpage.call_froms.count.to_s.ljust(6)

          depth_min = tpage.depth_min.to_s.ljust(4)
          depth_moy = tpage.depth_moy.to_s.rjust(5)
          depth_max = tpage.depth_max.to_s.rjust(5)

          csserr = tpage.errors_count > 0 ? 'red bold' : 'green'
          nb_errors = in_span(tpage.errors_count.to_s.rjust(4), class: csserr)

          # La ligne constituée
          in_div(iroute + froute + nb_links + nb_froms + depth_min + depth_moy + depth_max + nb_errors)
        end.join('') +
        '</div>'
        # /Fin de boucle sur toutes les routes
      end.join('')
      # /Fin de boucle sur tous les types de classement
    end
    # /Fin de data_all_routes


    def code_html
      # require 'erb'
      ERB.new(code_gabarit_html).result(bind)
    end
    def code_gabarit_html
      File.open(path_gabarit,'rb'){|f|f.read.force_encoding('utf-8')}
    end

    # ---------------------------------------------------------------------
    #   Méthodes fonctionnelles
    # ---------------------------------------------------------------------

    def bind; binding() end

    def in_tag tag, content, options = nil
      options ||= Hash.new
      attrs = []
      attrs << "id='#{options[:id]}'" if options.key?(:id)
      attrs << "class='#{options[:class]}'" if options.key?(:class)
      attrs << "style='#{options[:style]}'" if options.key?(:style)
      attrs = attrs.empty? ? '' : ' ' + attrs.join(' ')
      "<#{tag}#{attrs}>#{content}</#{tag}>"
    end
    def in_div content, options = nil; "\n\n" + in_tag('div', content, options) end
    def in_span content, options = nil; in_tag('span', content, options) end

    # Path du rapport
    def path
      @path ||= File.join(folder, "report_#{TestedPage.online? ? 'ONLINE' : 'OFFLINE'}.html")
    end
    def path_gabarit
      @path_gabarit ||= File.join(folder, 'gabarit.erb')
    end

    def folder
      @folder ||= File.join(MAIN_FOLDER,'output')
    end

  end #/ << self TestedPage::Report
  end #/Report

  # ---------------------------------------------------------------------
  # ATTENTION, ON REVIENT DANS TestedPage

  # Rapport console, lorsque le format de sortie est :brut/'brut'
  def report_console
    say "\n\n\n"
    say "="*80
    say "= ANALYSE DES LIENS DU #{Time.now}"
    say "="*80
    say "\n\n"
    say "= NOMBRE DE ROUTES TESTÉES : #{instances.count}"
    say "= NOMBRE PAGES INVALIDES   : #{invalides.count}"
    say "= NOMBRE PAGES VALIDES     : #{instances.count - invalides.count}"
    say "\n"

    say "\n==============================="
    say   "= 20 ROUTES LES PLUS VISITÉES ="
    say   "==============================="
    routes_les_plus_visitees.each do |tpage|
      say "= #{tpage.route} - #{tpage.call_count} fois"
    end
    say "\n================================="
    say   "= 10 ROUTES LES MOINS VISITÉES  ="
    say   "================================="
    routes_les_moins_visitees.each do |tpage|
      say "= #{tpage.route} - #{tpage.call_count} fois"
    end
    say "\n"

    # ---------------------------------------------------------------------
    #   Pages invalides
    if invalides.count > 0
      say "\n========================="
      say   "= PAGES INVALIDES (#{invalides.count}) ="
      say   "========================="
      invalides.each do |route|
        tpage = instances[route]
        errs = tpage.errors.join("\n")
        say "# Route : #{route}"
        say "# Invalidité : #{errs}"
      end
    else
      say "= AUCUNE PAGE INVALIDE ! ="
    end
  end
  # /Fin du rapport TestedPage::console

end #/TestedPage
