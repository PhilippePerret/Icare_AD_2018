# encoding: UTF-8

class IcModule
class IcEtape

  # Le travail propre formaté. Noter qu'il n'est inscrit que s'il
  # est défini. Ou dans le cas où ce n'est pas l'étape absolue seule
  # qui est affichée.
  #
  def travail_propre_formated
    ERB.new(travail_propre).result(self.bind)
  end

end #/IcModule
end #/IcEtape
