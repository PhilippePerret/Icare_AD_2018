# encoding: UTF-8
class IcModule
class IcEtape

  attr_reader :id
  def user_id           ; @user_id            ||= get(:user_id)           end
  def abs_etape_id      ; @abs_etape_id       ||= get(:abs_etape_id)      end
  def icmodule_id       ; @icmodule_id        ||= get(:icmodule_id)       end
  def numero            ; @numero             ||= get(:numero)            end
  def status            ; @status             ||= get(:status) || 0       end
  def started_at        ; @started_at         ||= get(:started_at)        end
  def started_at        ; @started_at         ||= get(:started_at)        end
  def expected_end      ; @expected_end       ||= get(:expected_end)      end
  def expected_comments ; @expected_comments  ||= get(:expected_comments) end
  def ended_at          ; @ended_at           ||= get(:ended_at)          end
  def documents         ; @documents          ||= get(:documents)         end
  # Pour le status, cf. state.rb
  # def status            ; @status             ||= get(:status)            end
  def options           ; @options            ||= get(:options)           end
  def travail_propre    ; @travail_propre     ||= get(:travail_propre).nil_if_empty end
  def updated_at        ; @updated_at         ||= get(:updated_at)        end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def owner ; @owner ||= User.new(user_id) end

  # Instance de l'étape absolue
  def abs_etape
    @abs_etape ||= begin
      site.require_objet 'abs_etape'
      AbsModule::AbsEtape.new(abs_etape_id)
    end
  end

  # L'IcModule de l'étape
  def icmodule
    @icmodule ||= begin
      site.require_objet 'ic_module'
      IcModule.new(icmodule_id)
    end
  end

end #/IcEtape
end #/IcModule
