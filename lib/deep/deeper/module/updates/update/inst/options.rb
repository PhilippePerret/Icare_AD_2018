# encoding: UTF-8
class SiteHtml
class Updates
class Update

  # Premier bit des options
  def importance
    options[0].to_i
  end

  # L'update est importante si son degré est
  # supérieur ou égal à 7
  def importante?
    (options||"")[0].to_s.to_i >= 7
  end

  # Deuxième bit
  # Savoir si l'actualité a été annoncée (quand elle doit l'être)
  # 0: Pas annoncée, 1: annoncée
  def announced?
    options[1].to_i == 1
  end

  # Troisième bit d'option
  # Savoir si l'actualité a été annoncée (quand elle doit l'être)
  # dans le mail hebdomadaire
  def weekly_announced?
    options[2].to_i == 1
  end

  # Pour définir que l'actualité a été annoncée dans le mail
  # quotidient
  def set_announced
    set(options: options.set_bit(1, 1))
  end
  # Pour définir que l'actualité a été annoncée dans le mail
  # hebdomadaire
  def set_weekly_annouced
    set(options: options.set_bit(2, 1))
  end

end #/Update
end #/Updates
end #/SiteHtml
