# encoding: UTF-8
class Database
class Table
  class << self

    # TRUE si le contenu doit être consulté sur la table
    # online quand on est en offline (en online, la case est cachée,
    # cette valeur est donc toujours nil)
    def online?
      @for_online = (ONLINE || param(:online) == '1') if @for_online === nil
      @for_online
    end

    # Retourne le code HTML dans un pre de toutes les données de la
    # table définie dans param(:tblname) de la base param(:dbname)
    #
    def _table_content
      table = site.dbm_table( param(:dbname), param(:tblname), online? )
      filter  = param(:filter).nil_if_empty
      columns = param(:columns).nil_if_empty
      options = Hash.new
      filter.nil? || begin
        # Par mesure de prudence, si le filtre ne commence par par { et qu'il
        # ne commence pas par des guillemets, on les ajoute.
        if !filter.start_with?('{') && !filter.numeric?
          filter.start_with?('"') || filter = "\"#{filter}\""
        end
        filter = eval(filter)
        options.merge!(where: filter)
      end
      columns.nil? || options.merge!(columns: columns)

      debug "options: #{options.inspect}"

      # Le résultat de chaque méthode doit être retournée
      # pour affichage
      case true
      when filter.instance_of?(Fixnum)
        get_row_content_editable table, options
      else
        get_table_content table, options
      end
    end

    # Retourne le contenu d'une table, prêt à l'affichage
    #
    # +table+ Table obtenue par site.dbm_table(<base suffixe>, <nom table>)
    def get_table_content table, options
      data =
        if options.nil?
          table.select
        else
          dbname = table.db_name.sub(/^#{site.prefix_databases}_/,'')
          request = Array.new
          request << "SELECT"
          request << (options[:columns] ? options[:columns] : "*")
          request << "FROM #{table.name}"
          options[:where].nil? || begin
            where = options[:where]
            where =
              case where
              when Hash
                where.collect do |k,v|
                  is_v =
                    case v
                    when NilClass then 'IS NULL'
                    else "= #{v.inspect}"
                    end
                  "#{k} #{is_v}"
                end.join(' AND ')
              else
                where
              end
            request << "WHERE #{where}"
          end
          request = request.join(' ')
          # debug "MYSQL REQUEST : #{request} (online? #{online?.inspect})"
          site.db_execute(dbname, request, {online: online?})
        end

      return "Cette table ne contient aucune valeur." if data.empty?

      # Format
      # ID handler titre path
      datacolumns = nil
      data.each do |rowdata|
        rowid = rowdata[:id]
        if datacolumns.nil?
          datacolumns = Hash.new
          rowdata.keys.each { |col| datacolumns.merge! col => { max_len: 0, name: col.to_s.freeze } }
        end
        rowdata.each do |col, valcol|

          if valcol.instance_of?(String)
            valcol = rowdata[col] = valcol.gsub(/<(.*?)>/,'').gsub(/[\r\t]/,'').gsub(/  +/,' ').gsub(/\n/,'[RC]')
          end

          if valcol.to_s.length > datacolumns[col][:max_len]
            datacolumns[col][:max_len] = valcol.to_s.length
          end
        end
      end

      # Lignes de titre + séparateur
      lentot = 0
      separateur = Array.new
      code = '| ' + datacolumns.collect do |col, datacol|
        max_len = [datacol[:max_len], datacol[:name].length].max
        datacol[:max_len] = max_len
        lentot += max_len + 3
        separateur << "-" * (max_len+2)
        datacol[:name].ljust(max_len)
      end.join(' | ') + ' |' + "\n"

      separateur = '|' + separateur.join('|') + '|' + "\n"
      code += separateur

      # Les données
      code += data.collect do |rowdata|
        rowid = rowdata[:id]

        '| ' + rowdata.collect do |col, value|
          value.to_s.force_encoding('utf-8').ljust(datacolumns[col][:max_len])
        end.join(' | ') + " |\n"

      end.join("")

      # La ligne de fin
      code += separateur
      code = '<pre style="font-size:13pt;">' + code + '</pre>'

    end
    #/ get_table_content






    # Affiche le contenu de la rangée définie par options[:filter]
    # mais sous forme de champs éditables.
    def get_row_content_editable table, options
      row_id = options[:where]
      row = table.get(row_id, colonnes: options[:columns])
      toutes_les_colonnes = options[:columns].nil? || options[:columns] == '*'
      colonnes_init = options[:columns].freeze # c'est un string
      # debug "row : #{row.inspect}"
      row != nil || (return "La rangée ##{row_id} est inconnue dans cette table.")

      # Un menu pour définir le type lorsque la valeur est nil
      menu_types = [
        ['String', 'String/raw'], ['Fixnum', 'Fixnum'], ['Float', 'Float'],
        ['NotNil', 'Not Nil'],
        ['Date', 'Date'], ['Time', 'Time']
      ].in_select(name: 'row[%{prop}][type]', id: 'row_%{prop}_type')

      # On affiche toute la donnée avec des champs les uns au-dessus des
      # autres pour modifier les valeurs.
      form =
        row.collect do |prop, value|
          value = value.nil_if_empty
          has_type = false == value.instance_of?(NilClass)
          is_time = prop.to_s.end_with?('_at') && value.instance_of?(Fixnum)

          class_input_text =
            if is_time
              'time'
            else
              case value
              when NilClass, Time, Date then 'milong'
              when Fixnum, Float
                if value < 100
                  'short'
                elsif value < 900
                  'medium'
                else
                  'milong'
                end
              else
                nil
              end
            end

          prop_field =
            case true
            when value.instance_of?(String) && value.match(/\n/)
              value.in_textarea(name: "row[#{prop}]", id: "row_#{prop}")
            else
              value.to_s.in_input_text(name: "row[#{prop}][value]", id: "row_#{prop}_value", class: class_input_text)
            end

          human_value =
            if prop == :user_id
              "(#{User.new(value).pseudo})"
            elsif prop.to_s.end_with?('_at') && value.instance_of?(Fixnum)
              # Une date
              value.as_human_date(true, true)
            else
              nil
            end

          # Le type du champ. S'il est nil, on met offre un menu pour
          # choisir le type. Sinon, on cache le type dans un champ hidden
          # pour convertir la donnée à l'enregistrement
          prop_type =
            case value
            when NilClass then menu_types % {prop: prop}
            else
              value.class.to_s.in_hidden(name: "row[#{prop}][type]", id: "row_#{prop}_type")
            end
          # Construction de la rangée
          (
            prop.inspect.in_span(class: 'libelle') +
            (
              "#{prop_field} #{prop_type} #{human_value}".strip
            ).in_span(class: 'value')
          ).in_div(class: 'row')
        end.join("\n")

      if OFFLINE
        # Un menu qui permet de définir si les modifications doivent toucher
        # la table online/offline ou les deux
        form += (
          'Modifier…'.in_span(class: 'libelle') +
          [['both', 'ONLINE + OFFLINE'], ['on', 'ONLINE'], ['off', 'OFFLINE']].in_select(name: 'lieu', id: 'lieu').in_span(class: 'value')
        ).in_div(class: 'row')
      end

      # Il faut ajouter toutes les données de la table, route, etc.
      form += param(:dbname)      .in_hidden(name: 'dbname')
      form += param(:tblname)     .in_hidden(name: 'tblname')
      form += param(:online)      .in_hidden(name: 'online')
      form += 'save_new_data_row' .in_hidden(name: 'operation')
      form += 'database/edit'     .in_hidden(name: 'route')
      form += page.html_separator(50)
      form += 'Enregistrer'       .in_a(class: 'btn btn-primary', onclick: "$.proxy(Database,'save_edited_row')()")
      form.in_form(id:'form_edit_row', class: 'container') +
        (toutes_les_colonnes ? explications_toutes_colonnes : rappel_colonnes(colonnes_init)).in_div(class: 'small italic air')

    rescue Exception => e
      debug e
      "ERREUR : #{e.message} (consulter le FICHER debug pour le détail)"
    end
    #/ get_row_content_editable

    def explications_toutes_colonnes
      "Pour n'éditer que quelques colonnes, il suffit d'en définir la liste dans le champ `colonnes` sour le bouton “Afficher/éditer”."
    end
    def rappel_colonnes cols
      "Seules les colonnes #{cols.split(', ').collect{|c| ":#{c}"}.pretty_join} ont demandées à être affichées"
    end


  end #/<< self
end #/Table
end #/Database
