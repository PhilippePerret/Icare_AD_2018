# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # ---------------------------------------------------------------------
  #   Propriété de la base
  # ---------------------------------------------------------------------
  attr_reader :id

  def user_id           ; @user_id            ||= get(:user_id)           end
  def abs_module_id     ; @abs_module_id      ||= get(:abs_module_id)     end
  def abs_etape_id      ; @abs_etape_id       ||= get(:abs_etape_id)      end
  def icmodule_id       ; @icmodule_id        ||= get(:icmodule_id)       end
  def icetape_id        ; @icetape_id         ||= get(:icetape_id)        end
  def doc_affixe        ; @doc_affixe         ||= get(:doc_affixe)        end
  def original_name     ; @original_name      ||= get(:original_name)     end
  def status            ; @status             ||= get(:status)            end
  def time_original     ; @time_original      ||= get(:time_original)     end
  def time_comments     ; @time_comments      ||= get(:time_comments)     end
  # Date estimée pour le retour des commentaires
  def expected_comments ; @expected_comments  ||= get(:expected_comments) end
  def cote_original     ; @cote_original      ||= get(:cote_original)     end
  def cote_comments     ; @cote_comments      ||= get(:cote_comments)     end
  def cotes_original    ; @cotes_original     ||= get(:cotes_original)    end
  def cotes_comments    ; @cotes_comments     ||= get(:cotes_comments)    end
  def readers_original  ; @readers_original   ||= get(:readers_original)  end
  def readers_comments  ; @readers_comments   ||= get(:readers_comments)  end
  def created_at        ; @created_at         ||= get(:created_at)        end
  def updated_at        ; @updated_at         ||= get(:updated_at)        end

  # Voir le fichier options.rb
  # def options;

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------

  def owner; @owner ||= User.new(user_id) end
  def icmodule
    @icmodule ||= begin
      site.require_objet 'ic_module'
      IcModule.new(icmodule_id)
    end
  end
  def icetape
    @icetape ||= begin
      site.require_objet 'ic_etape'
      IcModule::IcEtape.new(icetape_id)
    end
  end
  def absmodule
    @absmodule ||= begin
      site.require_objet 'abs_module'
      AbsModule.new(abs_module_id)
    end
  end
  def absetape
    @absetape ||= begin
      site.require_objet 'abs_etape'
      AbsModule::AbsEtape.new(abs_etape_id)
    end
  end

  # Extension du document
  def extension
    @extension ||= original_name.split('.').pop
  end

  # Retourne l'année et le trimestre du document
  def time
    @time ||= Time.at(created_at)
  end
  def annee
    @annee ||= time.year
  end
  def trimestre
    @trimestre ||= 1 + ((time.month - 1)/ 3)
  end

end #/IcDocument
end #/IcEtape
end #/IcModule
