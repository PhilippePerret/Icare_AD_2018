# encoding: UTF-8
class AbsModule

  # ---------------------------------------------------------------------
  #   Propriétés enregistrées dans la base de données
  # ---------------------------------------------------------------------

  # {Fixnum} Identifiant absolu et universel de l'étape absolue
  attr_reader :id

  def name              ; @name               ||= get(:name)              end
  alias :titre :name
  def tarif             ; @tarif              ||= get(:tarif)             end
  def nombre_jours      ; @nombre_jours       ||= get(:nombre_jours)      end
  def hduree            ; @hduree             ||= get(:hduree)            end
  def short_description ; @short_description  ||= get(:short_description) end
  def long_description  ; @long_description   ||= get(:long_description)  end
  # La version string, qui ne sert plus que pour le nom des fichiers
  # sur le QDD
  def module_id         ; @module_id          ||= get(:module_id)         end
  def created_at        ; @created_at         ||= get(:created_at)        end
  def updated_at        ; @updated_at         ||= get(:updated_at)        end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------


  # ---------------------------------------------------------------------
  #   Propriétés fonctionnelles
  # ---------------------------------------------------------------------
  def table ; @table ||= self.class.table end

end #/AbsModule
