# encoding: UTF-8
class Database
class Table
class << self

  def _save_row
    check_and_set_values

    base  = param(:dbname)
    table = param(:tblname)
    lieu  = param(:lieu) || 'on'
        # Le `|| 'on'` vient du fait qu'en ONLINE, on n'affiche pas
        # le menu pour indiquer si la transformation doit se faire
        # online ou offline, puisqu'elle ne peut se faire qu'en
        # online.

    # debug "@final_values : #{@final_values.inspect}"

    # === OPÉRATION ===
    mess = Array.new
    if ['both', 'on'].include?(lieu)
      res = insert_or_update_in(site.dbm_table(base, table, online = true))
      mess << "#{res} en ONLINE"
    end
    if ['both', 'off'].include?(lieu)
      res = insert_or_update_in(site.dbm_table(base, table, online = false))
      mess << "#{res} en OFFLINE"
    end
    mess = mess.join(' et ')

    flash "Données de la rangée ##{row_id} #{mess}."
  rescue Exception => e
    debug e
    error "ERREUR : #{e.message} (consulter le FICHIER debug pour le détail)."
  end

  def insert_or_update_in table
    wherecount = row.key?(:id) ? {id: row_id} : {ip: row[:ip]}
    @final_values.merge!(updated_at: Time.now.to_i)
    if table.count( where: wherecount ) > 0
      if row.key?(:id)
        table.update(row_id, @final_values)
      else
        table.update({where: wherecount}, @final_values)
      end
      return 'actualisée'
    else
      table.insert(@final_values)
      return 'créée'
    end
  end

  def row
    @row ||= param(:row)
  end
  def row_id
    @row_id ||= begin
      if row.key?(:id)
        row[:id][:value].to_i
      else
        nil
      end
    end
  end

  # Il faut mettre les valeurs dans leur état (type)
  def check_and_set_values
    hvalues = Hash.new
    row.each do |k, v|
      typ = v[:type]
      debug "k = #{k.inspect}"
      debug "typ = #{typ.inspect}"
      debug "v"
      val =
        if typ == 'NotNil'
          v[:value].strip
        else
          v[:value].nil_if_empty
        end
      debug "val = #{val.inspect}"
      # Sauf si val est nil, il faut lui donner la valeur conformément
      # à son type
      unless val.nil?
        val =
          case typ
          when 'String'   then val
          when 'Integer'   then val.to_i
          when 'Decimal'  then val.to_f
          when 'Date'     then Date.new(val) # bon ?
          when 'Time'     then Time.new(val) # bon ?
          else val
          end
      end
      # On ajoute cette valeur
      hvalues.merge!(k.to_sym => val)
    end
    @final_values = hvalues
  end
  # /check_and_set_values
end #<< self
end #/Table
end #/Database
