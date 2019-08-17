# encoding: UTF-8
raise_unless_admin

class SiteHtml
class Admin
class Console

  # Retourne la liste des gels
  def affiche_liste_des_gels
    site.require_module('Gel')
    t = Dir["#{Gel::folder}/*"].collect do |path|
      File.basename(path)
    end.join("\n").in_pre
    sub_log("<strong>Liste des gels</strong>\n#{t}")
    "Cf. la liste sous la table"
  end

  def gel gel_name
    site.require_module('Gel')
    if Gel::gel(gel_name)
      "Le site a été gelé dans `#{gel_name}`."
    else
      "Un problème est survenu au cours du gel."
    end
  end

  def degel gel_name
    site.require_module('Gel')
    if Gel::degel(gel_name)
      "Le gel `#{gel_name}` a été degelé."
    else
      "Le gel `#{gel_name}` n'a pas pu être dégelé."
    end
  end

end #/Console
end #/Admin
end #/SiteHtml
