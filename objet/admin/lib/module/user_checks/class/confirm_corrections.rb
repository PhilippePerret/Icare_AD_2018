class Admin
class Checker

  require_relative '_module_messages'
  require_relative '_module_props'
  require_relative '_module_handy'
  include MessagesMethods
  include CheckerPropsModule
  include HandyCheckerMethods

class << self
  def confirm_corrections
    add_title "=== Réparation à effectuer (ou non) ==="
    @main_bouton_name = "Procéder à la réparation"
    add_raw '&nbsp;'.in_div
    @fname_corrections = param(:fname_corrections)
    data_corrections.each do |db, data_db|
      data_db.each do |tb_name, tb_data|
        tb_data.each do |kid, value|
          debug "---- value = #{value.inspect}"
          case kid
          when 'insert'
            # Insertion de données
            # value est un array des données à insérer
            value.each do |hvalue|
              solution_id = hvalue.delete('solution_id')
              solution_id || next
              checked = param(solution_id)
              css = checked ? 'green bold' : 'red'
              msg = "#{checked ? 'OUI' : 'NON'} : #{solution_id}".in_div(class:css)
              add 'INSERT', "#{msg}#{hvalue.inspect.in_div}"
            end
          when 'delete'
            # Destruction de donnée
            # value est un array des données à détruire
            solutions_oui = solutions_non = []
            ids = value.collect do |hvalue|
              # Id de la solution (pour vérifier s'il faut procéder à l'opération)
              solution_id = hvalue.delete('solution_id')
              # Id de la donnée à détruire
              data_id = hvalue['value']
              solution_id || next
              checked = param(solution_id)
              checked ? solutions_oui << solution_id : solutions_non << solution_id
              checked ? data_id : nil
            end.compact
            checked = ids.empty? ? false : true
            css = checked ? 'green bold' : 'red'
            msg_oui = "OUI : #{solutions_oui.join(', ')}".in_div(class:'green bold')
            msg_non = "NON : #{solutions_non.join(', ')}".in_div(class:'red')
            add 'DELETE', "#{msg_oui}#{msg_non}"

          else
            # kid est l'identifiant de la donnée à modifier
            # value est le hash de données à modifier avec en clé la propriété et
            # en valeur un hash {:value, :solution_id}
            value.collect do |prop, svalue|
              solution_id = svalue.delete('solution_id')
              real_value  = svalue.delete('value')
              checked = param(solution_id)
              str1 = "#{checked ? 'OUI' : 'NON'} : #{solution_id}".in_div(class: checked ? 'green bold' : 'red')
              str2 = "Mettre #{prop} à #{real_value}".in_div
              add 'MODIFY', "#{str1}#{str2}"
            end
          end
        end
      end
    end
  end

  def data_corrections
    @data_corrections ||= begin
      JSON.parse(File.read(fpath_corrections))
    end
  end
end #/<< self
end #/Checker
end #/Admin
