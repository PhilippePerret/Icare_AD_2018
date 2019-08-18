# encoding: UTF-8
class IcModule


  # ---------------------------------------------------------------------
  #   Propriétés dans la base de données
  # ---------------------------------------------------------------------
  attr_reader :id
  def user_id       ; @user_id        ||= get(:user_id)       end
  def abs_module_id ; @abs_module_id  ||= get(:abs_module_id) end
  def icetape_id    ; @icetape_id     ||= get(:icetape_id)    end
  def project_name  ; @project_name   ||= get(:project_name)  end
  def icetapes      ; @icetapes       ||= get(:icetapes)      end
  def next_paiement ; @next_paiement  ||= get(:next_paiement) end
  def paiements     ; @paiements      ||= get(:paiements)     end
  def pauses        ; @pauses         ||= get(:pauses)        end
  def started_at    ; @started_at     ||= get(:started_at)    end
  def ended_at      ; @ended_at       ||= get(:ended_at)      end
  def updated_at    ; @updated_at     ||= get(:updated_at)    end

  # Cf. le fichier options.rb
  # def options; end

  # ---------------------------------------------------------------------
  #   Propriétés volatiles
  # ---------------------------------------------------------------------
  def owner; @owner ||= User.new(user_id) end
  alias :icarien :owner

  def abs_module
    @abs_module ||= begin
      site.require_objet 'abs_module'
      AbsModule.new(abs_module_id)
    end
  end

  def icetape
    @icetape ||= begin
      site.require_objet 'ic_etape'
      IcModule::IcEtape.new(icetape_id)
    end
  end

  def icetapes_ids
    @icetapes_ids ||= icetapes.as_list_num_with_spaces
  end

  def paiements_ids
    @paiements_ids ||= paiements.as_list_num_with_spaces
  end

end #/IcModule
