# encoding: UTF-8
class IcModule
class IcEtape
class IcDocument

  # Dans ces trois méthodes d'état, +ty+ doit être
  # :original ou :comments. Si +ty+ est nil, la méthode retourne
  # true si les documents existants (original et commentaires) sont
  # partagés.
  def shared? ty = nil
    if ty.nil?
      # Il faut tester les deux documents
      if has?(:original)
        acces(:original) == 1 || ( return false )
      end
      if has?(:comments)
        acces(:comments) == 1 || ( return false )
      end
      return true
    else
      has?(ty) && acces(ty) == 1
    end
  end
  def has?        ty ; options[ty == :original ? 0 : 8].to_i == 1   end
  def downloaded? ty ; options[ty == :original ? 2 : 10].to_i == 1  end
  def complete?   ty ; options[ty == :original ? 5 : 13].to_i == 1  end

  # TRUE si c'est un document pour l'inscription
  def inscription?
    @for_signup = (abs_module_id == 0 && abs_etape_id == 0) if @for_signup === nil
    @for_signup
  end

end #/IcDocument
end #/IcEtape
end #/IcModule
