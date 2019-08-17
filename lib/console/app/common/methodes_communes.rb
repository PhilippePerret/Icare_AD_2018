# encoding: UTF-8
=begin

Module qui contient les traitements des balises pour les textes ou les
fichier erb.

    balise <chose> <désignation chose>[ <format sortie>]

Exemples
--------

    balise livre documents erb
    # => "<%= lien.livre_les_documents %>"

    balise mot protag
    # => "MOT[8|protagoniste]" et autres mots contenant "protag"
    balise mot protag ERB
    # => "<%= MOT[8|protagoniste] %>" et autres mots contenant "protag"

=end
raise_unless_admin

class SiteHtml
class Admin
class Console

  # = main =
  #
  # Méthode principale de traitement des commandes commençant par
  # `balise <chose> etc.`. Produit des champs de saisie où on peut
  # récupérer le code fourni.
  #
  # Chaque méthode appelée doit retourner un Array avec en
  # premier élément :
  #   Un {Array} content des Hash (un par balise à proposer)
  #   contenant :value (valeur à proposer), :after (texte quelconque
  #   à ajouter après)
  # Et en second élément :
  #   Le message à retourne ("" si nil)
  # +bdata+
  def main_traitement_balise bdata
    debug "bdata : #{bdata.inspect}"
    bdata[1] = bdata[1].gsub(/^["'](.*?)["']$/,'\1')
    balises, message = case bdata[0]
    when 'film'
      console.require 'filmodico'
      give_balise_of_filmodico(bdata[1])
    when 'mot'
      console.require 'scenodico'
      give_balise_of_scenodico(bdata[1])
    when 'livre'
      console.require 'narration'
      give_balise_of_livre(bdata[1])
    when 'page'
      console.require 'narration'
      give_balise_of_page(bdata[1])
    when /analyses?/
      console.require 'analyses'
      Analyses.instance.liens_balises_vers(bdata[1])
    when 'question'
      console.require 'narration'
      give_balise_of_question(bdata[1])
    when 'checkup'
      console.require 'narration'
      give_balise_of_checkup(bdata[1])
    end

    as = case bdata[2]
    when '', nil then nil
    else bdata[2].downcase
    end

    message ||= ""

    return message if balises.nil? # aucune trouvée

    sub_log( liste_built_balises(balises, as) + rappels_balises(as) )
    return ""
  end

  def rappels_balises as
    c = ""
    unless as == 'erb'
      c << ("Rappel : Vous pouvez utiliser `ERB` ou `erb` à la fin de la commande pour obtenir une balise ERB.").in_div(class:'tiny italic')
    end
    c
  end

  # Méthode qui reçoit la liste des balises et les affiche sous
  # la console (sub_log)
  # Chaque élément de {Array} +arr_balises+ doit contenir au
  # moins :value, la valeur à donner et peut contenir :
  # :after    Texte à écrire après le champ
  def liste_built_balises arr_balises, as = 'md'
    arr_balises.collect do |hbalise|
      hbalise[:value] = "<%= #{hbalise[:value]} %>" if as == 'erb'
      c = "<input type='text' value='#{hbalise[:value]}' style='width:400px'/>"
      c << " #{hbalise[:after]}" unless hbalise[:after].nil?
      c.in_div
    end.join + '<script type="text/javascript">UI.auto_selection_text_fields()</script>'
  end

end #/Console
end #/Admin
end #/SiteHtml
