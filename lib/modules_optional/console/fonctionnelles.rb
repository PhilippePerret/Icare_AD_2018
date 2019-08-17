# encoding: UTF-8
# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  # Chargement d'un module application
  # Note : C'est un dossier qui doit se trouver dans le dossier
  # ./lib/app/console/
  # @usage : console.load('NOM_DOSSIER')
  # Note : pour pouvoir utiliser la méthode `require` normalement,
  # on teste l'existence de `folder_name` et `folder_name.rb`
  alias :top_require :require
  def require folder_name
    if File.exist?(folder_name.to_s) || File.exist?("#{folder_name}.rb")
      top_require folder_name.to_s
    else
      (folder_app + folder_name).require
    end
  end
  alias :load :require

  # Chargement d'un dossier de sub-méthodes
  def require_submethods folder_name
    (folder_console + "submethods/#{folder_name}").require
  end

  # Une ligne à ajouter au code exécuté, qui sera remis dans
  # la console
  def add_code line
    @new_code << line
  end
  # ---------------------------------------------------------------------
  #   Méthodes fonctionnelles
  # ---------------------------------------------------------------------

  def init
    @messages = Array::new
    @new_code = Array::new
    return self
  end

  # Return false si la console est vide ou espace/retour
  def has_code?
    code != nil
  end

  # Les lignes de code comme un Array qui ne contient aucune
  # ligne vide ni aucun commentaire
  def lines
    @lines ||= begin
      code.gsub(/\r/,'').split("\n").collect do |line|
        line.strip!
        next nil if line == "" || line.start_with?('#')
        line
      end.compact
    end
  end

  # Le code épuré au début et à la fin
  def code
    @code ||= param(:console).nil_if_empty
  end

  # Enregistrer un message pour la sortie des opérations
  def log mess, css = nil
    @messages << mess.in_div(class: css.to_s)
  end

end #/Console
end #/Admin
end #/SiteHtml
