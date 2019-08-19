# encoding: UTF-8
=begin

  Méthodes d'instance pour la gestion des ic-étapes de l'user

=end
class User

  def icetape
    @icetape ||= begin
      if icmodule && icmodule.icetape_id
        site.require_objet 'ic_etape'
        IcModule::IcEtape.new(icmodule.icetape_id)
      else
        nil
      end
    end
  end

  # Les étapes de l'user gérées comme un ensemble
  # Note : je crois que le module 'icetapes' n'existe pas encore
  def icetapes
    @icetapes ||= begin
      User.require_module 'icetapes'
      IcModules::IcEtapes.new(self)
    end
  end
end
