# encoding: UTF-8


class SiteHtml
class TestSuite
class Case

  # Reçoit le message final de résultat et remplace les
  # éventuel _SUJET_ et _OBJET_ par leur valeur.
  def formate_message mess
    return mess if !(mess.match(/_SUJET_/) || mess.match(/_OBJET_/))
    mess.gsub!(/_SUJET_/, sujet_formated)
    mess.gsub!(/_OBJET_/, objet_formated)
  end

  def sujet_formated
    @sujet_formated ||= (sujet_name || sujet_valeur).to_s
  end

  # Permet de formater un "objet" dans les messages
  # de success ou de failure pour l'objet, c'est-à-dire pour
  # la chose à laquelle est comparée le _sujet_.
  # Si +objet_name+ est nil, c'est sa objet_valeur qui sera renvoyée
  # et donc affichée.
  # Si +objet_name+ est défini, c'est lui qui est renvoyé avec
  # sa objet_valeur entre parenthèses. Si objet_name ne commence pas
  # par "au" ou par "à", alors on lui ajoute "à"
  #
  # Cette méthode est utilisée par toutes les méthodes
  # de cas (les case-méthodes)
  #
  # Exemples
  #   objet_formated(nil, 6)
  #   => "6"
  #   objet_formated("bon", 6)
  #   => "à bon (6)"
  #   objet_formated("au nombre d'inscrits", 6)
  #   => "au nombre d'inscrits (6)"
  #   objet_formated("à eux", 6)
  #   => "à eux (6)"
  #
  def objet_formated
    if objet_name.nil?
      "à #{objet_valeur}"
    else
      objet_name.start_with?('au') || objet_name.start_with?('à') || (objet_name += 'à ')
      objet_name += " (#{objet_valeur})"
      objet_name
    end.to_s
  end

end #/Case
end #/TestSuite
end #/SiteHtml
