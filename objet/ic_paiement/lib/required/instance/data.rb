# encoding: UTF-8
class IcPaiement

  # ---------------------------------------------------------------------
  #   Propriétés de la base
  # ---------------------------------------------------------------------
  attr_reader :id

  def user_id     ; @user_id      ||= get(:user_id)     end
  def icmodule_id ; @icmodule_id  ||= get(:icmodule_id) end
  def montant     ; @montant      ||= get(:montant)     end
  def facture     ; @facture      ||= get(:facture)     end
  def created_at  ; @created_at   ||= get(:created_at)  end
  def updated_at  ; @updated_at   ||= get(:updated_at)  end

  # ---------------------------------------------------------------------
  #   Propriétés volatile
  # ---------------------------------------------------------------------

  def owner ; @owner ||= User.new(user_id)  end
  def icmodule
    @icmodule ||= begin
      site.require_objet 'ic_module'
      IcModule.new(icmodule_id)
    end
  end
  def abs_module ; @abs_module ||= icmodule.abs_module end

end #/IcPaiement
