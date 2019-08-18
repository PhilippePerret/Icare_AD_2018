# encoding: UTF-8
class SiteHtml
class Updates

  class << self


    # Création d'une nouvelle update dans la table
    def new_update data
      u = Update.new(data.merge(correct_values: true))
      u.create
    end

    # {SiteHtml::DBM_TABLE} La table contenant l'historique des updates
    def table_updates
      @table_updates ||= site.dbm_table(:cold, 'updates')
    end
    alias :table :table_updates

    # Quand c'est l'administrateur qui visite la page, on propose
    # une liste d'updates à ajouter. Cela sert surtout lorsque
    # l'on a oublié d'en faire et avant que la plupart des updates
    # puissent être automatisées.
    #
    def propositions
      # debug "-> propositions"
      # On va prendre toutes les actualisations des deux
      # derniers mois
      ago = Time.now.to_i - 60.days
      # debug "   ago : #{ago} (#{Time.at(ago)})"

      # On relève les updates des deux derniers mois
      debug "Nombre d'updates : #{table.count}"
      last_updates = {}
      dselect = {
        where: "created_at >= #{ago}"
      }
      table.select(dselect).each do |udata|
        # Inutile de prendre les updates sans route
        next if udata[:route].nil?
        last_updates.merge!( udata[:route] => udata )
      end

      # Proposition par rapport aux pages narration
      reqdata = {
        where:    "updated_at > #{ago}",
        colonnes: [:titre, :options],
        order:    'updated_at DESC'
      }
      pages_narration =
        site.dbm_table(:cnarration, 'narration').select(reqdata).collect do |pdata|
          pid = pdata[:id]
          # On ne prend que les pages, pas les chapitres/sous-chapitres
          next if pdata[:options][0] != '1'
          # On ne prend que les pages dont le niveau de développement
          # est suffisant pour la lecture.
          next if pdata[:options][1].to_i < 8
          # On ne prend que les pages qui n'ont pas fait l'objet
          # d'une annonce d'update dans les deux derniers mois
          next if last_updates.key?( route_for_page_narration(pid) )
          # Dans tous les cas contraires, on mémorise cette proposition
          # d'actualisation
          pdata[:titre].in_checkbox(name: "updates[page_narration-#{pid}]", checked: true).in_div
        end.compact.join('')

      # Les analyses de film
      reqdata.merge!(colonnes: [:titre, :titre_fr, :realisateur, :options])
      analyses_films =
        site.dbm_table(:biblio, 'films_analyses').select(reqdata).collect do |fdata|
          fid = fdata[:id]
          # debug "fdata = #{fdata.inspect}"
          # Ne pas prendre les films sans options
          fdata[:options] || next
          # Ne prendre que les films qui sont analysés
          fdata[:options][0] == '1' || next
          # Ne prendre que les analyses lisibles
          fdata[:options][4] == '1' || next
          # Ne prendre que les analyses qui ne possèdent pas
          # déjà une annonce dans les updates (on le teste par la
          # route)
          next if last_updates.key?( route_for_analyse_film(fid) )
          # Dans tous les autres cas, on garde cette proposition
          fdata[:titre].force_encoding('utf-8').in_checkbox(name:"updates[analyse_film-#{fid}]", checked: true).in_div
        end.compact.join('')

      'Pages Narrations'.in_h3 +
      pages_narration +
      'Analyses de films'.in_h3 +
      analyses_films
    end

    # Les méthodes pour construire les routes, pour pouvoir
    # les utiliser aussi bien dans les actualisations automatiques
    # que dans les propositions d'actualisation à l'administrateur
    # ou la vérification de la présence des actualisations.
    def route_for_page_narration pid
      "page/#{pid}/show?in=cnarration"
    end
    def route_for_analyse_film fid
      "analyse/#{fid}/show"
    end
    def route_for_video vid
      "video/#{vid}/show"
    end

    # On ajoute les updates choisies
    #
    # RETURN La liste des actualisations ajoutées, comme une
    # liste
    def add_updates
      raise_unless_admin

      # Données des livres de Narration
      require './_objet/cnarration/lib/required/constants.rb'

      @liste_updates = []
      param(:updates).each do |id, value_on|
        id = id.to_s
        case id
        when /^analyse_film/
          fid = id.split('-')[1].to_i
          dfilm = site.dbm_table(:biblio, 'films_analyses').get(fid)
          # S'il y a plus de trois mois entre la création et
          # l'actualisation, alors c'est une actualisation,
          # sinon c'est une création
          diff = dfilm[:updated_at] - dfilm[:created_at]
          is_actu = diff > 90.days
          titre = is_actu ? 'Actualisation de l’analyse du film' : 'Nouvelle analyse de film :'
          data_update = {
            message: "#{titre} #{dfilm[:titre]}",
            type:     'analyse',
            le:       dfilm[:updated_at],
            route:    route_for_analyse_film(fid),
            annonce:  2
            }
        when /^page_narration/
          pid = id.split('-')[1].to_i
          # -> MYSQL NARRATION
          dpage   = site.dbm_table(:cnarration,'narration').get(pid)
          dlivre  = Cnarration::LIVRES[dpage[:livre_id]]
          diff = dpage[:updated_at] - dpage[:created_at]
          is_actu = diff > 90.days
          titre = is_actu ? 'Actualisation de la page' : 'Nouvelle page de cours :'
          data_update = {
            message:  "Col. Narration : #{dpage[:titre]} (#{dlivre[:hname]})",
            type:     'narration',
            route:    route_for_page_narration(pid),
            le:       dpage[:updated_at],
            annonce:  1
          }
        else
          @liste_updates << "# IMPOSSIBLE DE VOIR CE QU'EST #{id}"
          next
        end

        # On ajoute l'actualisation
        @liste_updates << data_update[:message] + " (" + 'voir'.in_a(href: data_update[:route]) + ")"
        Update.new(data_update.merge(correct_values: true)).create

      end
      'Actualisations ajoutées'.in_h3 + @liste_updates.join('<br>')
    end

  end #<< self
end #/Updates
end #/SiteHtml
