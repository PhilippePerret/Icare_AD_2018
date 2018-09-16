# encoding: UTF-8
class AbsModule
class AbsEtape
class AbsTravailType

  # ---------------------------------------------------------------------
  #   Propriétés de base de données
  # ---------------------------------------------------------------------

  attr_reader :id
  def short_name  ; @short_name ||= get(:short_name)  end
  def rubrique    ; @rubrique   ||= get(:rubrique)    end
  def titre       ; @titre      ||= get(:titre)       end
  def travail     ; @travail    ||= get(:travail)     end
  def objectif    ; @objectif   ||= get(:objectif)    end
  def methode     ; @methode    ||= get(:methode)     end
  def liens       ; @liens      ||= get(:liens)       end
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # Identifiant humain pour introduire dans les travaux des étapes
  def human_id
    @human_id ||= "#{rubrique}/#{short_name}/#{id}"
  end

end #/AbsTravailType
end #/AbsEtape
end #/AbsModule
