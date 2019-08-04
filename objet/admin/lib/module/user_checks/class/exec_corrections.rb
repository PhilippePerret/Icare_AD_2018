class Admin
class Checker

  require_relative '_module_messages'
  require_relative '_module_props'
  require_relative '_module_handy'
  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

class << self
  def execute_corrections
    add_title "=== Réparation ==="
    @main_bouton_name = nil
    add_raw '&nbsp;'.in_div
    @fname_corrections = param(:fname_corrections)
    debug "---- data_corrections = #{data_corrections.pretty_inspect}"
    data_corrections.each do |db, data_db|
      data_db.each do |tb_name, tb_data|
        tb_data.each do |kid, value|
          case kid
          when 'insert'
            # Insertion de données
            # value est un array des données à insérer
            value.each do |hvalue|
              columns = []
              values  = hvalue.collect do |prop, val|
                columns << "#{prop} = ?"
                val
              end
              request = "INSERT INTO #{tb_name} SET #{columns.join(', ')}"
              if exec_operation(db, request, values)
                add 'INSERT', "#{db}.#{tb_name} #{hvalue.inspect}… OK".in_div(class:'green bold')
              end
            end
          when 'delete'
            # Destruction de donnée
            # value est un array des données à détruire
            # Les ids à détruire
            ids = value.collect{|h|h['value']}.uniq
            request = "DELETE FROM #{tb_name} WHERE id IN (#{ids.join(', ')})"
            if exec_operation(db, request)
              add 'DELETE', "#{db}.#{tb_name} IDS: #{ids.inspect}… OK".in_div(class:'green bold')
            end
          else
            # kid est l'identifiant de la donnée à modifier
            # value est le hash de données à modifier avec en clé la propriété et
            # en valeur un hash {:value, :solution_id}
            # Préparation de la requête
            request = "UPDATE #{tb_name} SET "
            values  = []
            modifs  = []
            value.each do |hvalue|
              request += "#{hvalue['property']} = ?"
              values << hvalue['value']
              modifs << "#{hvalue['property']} = #{hvalue['value']}"
            end

            if exec_operation(db, request, values)
              add 'MODIFY', "#{db}.#{tb_name} ##{kid} : #{modifs.join(', ')}… OK".in_div(class:'green bold')
            end
          end
        end
      end
    end
  end

  def exec_operation(db, request, values = nil)
    debug "Request: #{request} / values = #{values.inspect}"
    res = site.db_execute( db, request, {values: values} )
    debug "retour : #{res.inspect}"
    return true
  rescue Exception => e
    add 'ERROR', ("Avec la requête #{request} dans #{db}".in_div + e.message).in_div(class:'red bold')
    debug e
    return false
  end

end #/<< self
end #/Checker
end #/Admin
