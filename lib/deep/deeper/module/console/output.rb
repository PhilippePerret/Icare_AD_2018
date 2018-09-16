# encoding: UTF-8

class SiteHtml
class Admin
class Console


  # Le nouveau code qui sera affiché dans la console
  def code_console
    @code_console ||= @new_code.join("\n") + "\n"
  end


  # Sortie spéciale qui ne se fait pas dans la console mais
  # en dessous. Utile pour les affichages un peu spéciaux, comme
  # les contenus de table particulièrement larges
  # Alias : def sub_log
  def special_output code = nil
    if code.nil?
      @special_output || ""
    else
      @special_output ||= ""
      @special_output << code
    end
  end
  alias :sub_log :special_output

  # Sortie pour afficher le résultat des opérations
  def output
    return "" # on ne retourne plus rien pour le moment
    "Résultat de l'opération".in_h3 +
    @messages.join('')
  end


end #/Console
end #/Admin
end #/SiteHtml
