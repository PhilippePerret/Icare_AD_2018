# encoding: UTF-8
class AbsModule
class AbsEtape

  # ---------------------------------------------------------------------
  #   Propriétés enregistrées dans la base de données
  # ---------------------------------------------------------------------

  # {Integer} Identifiant absolu et universel de l'étape absolue
  attr_reader :id

  def numero      ; @numero     ||= get(:numero)      end
  def module_id   ; @module_id  ||= get(:module_id)   end
  def titre       ; @titre      ||= get(:titre)       end
  def travail     ; @travail    ||= get(:travail)     end
  def duree       ; @duree      ||= get(:duree)       end
  def duree_max   ; @duree_max  ||= get(:duree_max)   end
  def objectif    ; @objectif   ||= get(:objectif)    end
  def methode     ; @methode    ||= get(:methode)     end
  def travaux     ; @travaux    ||= get(:travaux)     end
  def liens       ; @liens      ||= get(:liens).nil_if_empty end
  def created_at  ; @created_at ||= get(:created_at)  end
  def updated_at  ; @updated_at ||= get(:updated_at)  end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  # {AbsModule} Module d'apprentissage absolu contenant cette
  # étape
  def abs_module
    @abs_module ||= begin
      site.require_objet 'abs_module'
      AbsModule.new(module_id)
    end
  end

  # ---------------------------------------------------------------------
  #   Propriétés fonctionnelles
  # ---------------------------------------------------------------------
  def table ; @table ||= self.class.table end

end #/AbsEtape
end #/AbsModule
