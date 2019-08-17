# encoding: UTF-8
=begin
  Méthodes utiles pour produire un rapport fichier des résultats
  obtenus au cours des recherches de positionnement Google.
=end
class Ranking

  # Nombre minimum de citations pour que le site soit affiché
  CITATIONS_MINIMUM = 2

  class << self

    def build_html_file options = nil
      options ||= Hash.new
      path_html_report.remove if path_html_report.exist?
      path_html_report.write whole_html_code
      if options[:open]
        `open -a Firefox "#{path_html_report.expanded_path}"`
      end
    end

    def whole_html_code
      '<html>'+
      head +
      body +
      '</html>'
    end

    def head
      '<head>'+
      '<meta http-equiv="Content-type" content="text/html; charset=utf-8">' +
      '<style type="text/css">'+style_css+'</style>'+
      "<title>Ranking check</title>" +
      '</head>'
    end
    def body
      '<body>'+
      div_positionnement +
      '</body>'
    end

    def div_positionnement

      # On construit d'abord les éléments pour récupérer les
      # données générales
      build_div_positionnement
      build_div_positionnement_total

      (
        'Données générales'.in_h2 +
        div_donnees_generales +
        'Positionnement général'.in_h2 +
        div_positionnement_total +
        'Positionnement par mot-clé'.in_h2 +
        div_positionnement_per_keyword
      ).in_div(id: 'positionnement_report')
    end

    def div_positionnement_per_keyword; @div_positionnement_per_keyword end
    def div_positionnement_total; @div_positionnement_total end
    def all_per_domain ; @all_per_domain  end

    def nombre_total_sites; @nombre_total_sites end
    def nombre_sites_minimum_citations; @nombre_sites_minimum_citations end
    #
    def div_donnees_generales
      (
        "Date : #{Time.now.to_i.as_human_date(true, true, '&nbsp;', 'à')}".in_div +
        div_infos_site_courant +
        "Nombre total de sites : #{nombre_total_sites}".in_div +
        "Nombre sites au-dessus de #{CITATIONS_MINIMUM} citations : #{nombre_sites_minimum_citations}"
      ).in_fieldset(id: 'data_generales')
    end

    def div_infos_site_courant
      data_site_courant = all_per_domain[site.domain_url]



      nombre_citations, index_liens, keywords =
        if data_site_courant.nil?
          [0, '- aucun -', '- aucun -']
        else
          # On construit la liste des mots-clés qui contiennent le site,
          # avec le nombre citations
          nombre_liens = data_site_courant[:nombre_liens]

          # On fait la liste des mots-clés en créant une table
          # avec en clé le mot clé et en valeur la liste des indexes.
          # Pour le moment, on indiquera juste le nombre d'indexes
          # TODO Utiliser la liste précise des indexes
          liste_keywords = Hash.new
          nombre_liens.times.each do |ilien|
            kw  = data_site_courant[:keywords][ilien]
            ikw = data_site_courant[:index_liens]
            liste_keywords.key?(kw) || liste_keywords.merge!(kw => Array.new)
            liste_keywords[kw] << ikw
          end
          # Le texte qui sera affiché
          donnee_keywords = liste_keywords.collect{|kw, arr_indexes| "#{kw}:#{arr_indexes.count}:#{arr_indexes.join(',')}"}.join(', ')

          [nombre_liens, data_site_courant[:index_liens].join(', '), data_site_courant[:keywords].join(', '), donnee_keywords]
        end
      (
        "Nombre de citations du site courant : #{nombre_citations}".in_div +
        "Indexes des citations : #{index_liens}".in_div +
        "Classement par mots-clés"
      ).in_div(id: 'data_site_courant')
    end

    # Le positionnement général de chaque domaine relevé
    def build_div_positionnement_total
      @div_positionnement_total =
        all_per_domain.sort_by{|d,dd| dd[:nombre_liens]}.reverse.collect do |dom, ddom|
          ddom[:nombre_liens] >= CITATIONS_MINIMUM || next
          @nombre_sites_minimum_citations += 1
          (
            "#{dom.in_a(href: dom, target: :new)} (citations : #{ddom[:nombre_liens]})".in_div(class: 'name') +
            "Index dans les recherches : #{ddom[:index_liens].join(', ')}".in_div(class: 'index_liens')
          ).in_div(class: 'domain')
        end.compact.join('').in_div(id: 'positionnement_general', class: 'domains')
    end

    # Le positionnement de chaque domaine par mot-clé de recherche
    def build_div_positionnement
      # Pour le moment, on rassemble ici tous les résultats complets
      @all_per_domain = Hash.new
      @nombre_total_sites = 0
      @nombre_sites_minimum_citations = 0

      @data_marshal = nil # pour forcer la lecture du fichier
      # puts "data_marshal : #{data_marshal.inspect}"
      @div_positionnement_per_keyword =
        data_marshal.collect do |keyword, data_kw|
          data_kw[:resultats] != nil || next
          # puts "data_kw : #{data_kw.inspect}"
          # puts "data_kw[:resultats] : #{data_kw[:resultats].inspect}"
          # puts "data_kw[:resultats][:per_domain] : #{data_kw[:resultats][:per_domain].inspect}"
          # break
          sorted = data_kw[:resultats][:per_domain].sort_by{|d,dd| dd[:nombre_liens]}.reverse
          keyword.in_div(class: 'keyword') +
          sorted.collect do |domain, data_domain|
            # On rassemble toutes les citations
            @all_per_domain.key?(domain) || begin
              @nombre_total_sites += 1
              @all_per_domain.merge!(domain => {
                nombre_liens: 0,
                index_liens:  Array.new,
                keywords:     Array.new
                })
            end
            @all_per_domain[domain][:nombre_liens] += data_domain[:nombre_liens]
            @all_per_domain[domain][:index_liens]  += data_domain[:index_liens]
            @all_per_domain[domain][:keywords]     += data_domain[:keywords]

            data_domain[:nombre_liens] >= CITATIONS_MINIMUM || next
            (
              domain.in_a(href: domain, target: :new).in_div(class: 'name') +
              data_domain[:index_liens].join(', ').in_div(class: 'index_liens') +
              data_domain[:founds_data].collect{|h| h[:titre]}.join(', ').in_div(class: 'titres_liens') +
              data_domain[:founds_data].collect{|h| h[:href].in_li}.join('').in_ul(class: 'href_liens')
            ).in_div(class: 'domain')
          end.uniq.join('').in_div(id: 'positionnement_per_keyword', class: 'domains')
        end.join('')
    end
    # /build_div_positionnement

    def style_css
      @style_css || file_style_css.read
    end
    def file_style_css
      @file_style_css ||= SuperFile.new(_('../css/main.css'))
    end

    def path_html_report
      @path_html_report ||= SuperFile.new('./tmp/ranking/html_report.html')
    end

  end #/<< self
end #/Ranking
